# Building and testing locally

Install the [development environment](development.md) first.

## Build

```bash
scripts/build.sh
```

Tunable via env:

| Variable          | Default                                                          | Purpose                                                 |
| ----------------- | ---------------------------------------------------------------- | ------------------------------------------------------- |
| `IMAGE`           | `kiln:dev`                                                       | Tag to apply to the built image                         |
| `BUILD_MODE`      | `direct`                                                         | `direct` (FROM Wolfi) or `bootstrap` (alpine→scratch)   |
| `WOLFI_BASE`      | `cgr.dev/chainguard/wolfi-base:latest`                           | Wolfi base image used in direct mode                    |
| `BOOTSTRAP_IMAGE` | `docker.io/library/alpine:3.21`                                  | Image whose `apk-tools` drives the bootstrap (fallback) |
| `NODE_MAJOR`      | `22`                                                             | Node major version (`nodejs-${NODE_MAJOR}`)             |
| `PYTHON_MINOR`    | `3.13`                                                           | Python minor series (`python-${PYTHON_MINOR}`)          |
| `WOLFI_REPO`      | `https://packages.wolfi.dev/os`                                  | apk repository URL                                      |
| `WOLFI_KEY_URL`   | `https://packages.wolfi.dev/os/wolfi-signing.rsa.pub`            | apk signing key URL                                     |
| `PLATFORM`        | `linux/amd64`                                                    | `docker buildx --platform` value                        |
| `PUSH`            | `0`                                                              | Set to `1` to push directly from buildx                 |

## Test

`scripts/test.sh` requires a locally built image and runs the
bundled smoke workflow under act. Run `scripts/build.sh` first. The smoke workflow exercises shell,
coreutils, node, python, build chain, git, gh, docker CLI, sudo, and the
`actions/checkout@v7` JS action against the runtime.

## Build modes

The Dockerfile has two routes to a Wolfi runtime, selected via
`--build-arg BUILD_MODE=...`:

- **`direct` (default)** — `FROM ${WOLFI_BASE}`, `apk add` packages on top.
  This is the canonical path. Default `WOLFI_BASE` is
  `cgr.dev/chainguard/wolfi-base:latest`, which is publicly pullable.

- **`bootstrap` (fallback)** — `FROM ${BOOTSTRAP_IMAGE}` (alpine); use that
  image's `apk-tools` to install Wolfi packages from `packages.wolfi.dev/os`
  into `/rootfs`, then start the final stage `FROM scratch` and copy
  `/rootfs` in. No Alpine binaries end up in the runtime. Use this when your
  environment can't pull `cgr.dev/chainguard/*` (registry allowlist).

Both modes produce a 100% Wolfi runtime. CI tests both modes; publish uses `direct` mode.

Longer rationale and the usrmerge / `--no-scripts` details for bootstrap
mode: see [`architecture.md`](architecture.md).

## Brand assets

The canonical [brand library](../assets/brand/README.md) supplies the README
banner and the documentation's light/dark logos. Check its asset manifest with:

```bash
bun run brand:check
```

After reviewing intentional asset changes, run
`bun run brand:update` and commit the updated manifest. This check also runs
through the shared local, hook, and CI checks with the existing Bun toolchain.
