# Building and testing locally

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
| `PUSH`            | `0`                                                              | Set to `1` to `docker push` after build                 |

## Test

`scripts/test.sh` builds the image (if not already present) and runs the
bundled smoke workflow under act. The smoke workflow exercises shell,
coreutils, node, python, build chain, git, gh, docker CLI, sudo, and the
`actions/checkout@v4` JS action against the runtime.

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
  environment can't pull `cgr.dev/chainguard/*` (registry allowlist, air-gap).

Both modes produce a 100% Wolfi runtime. CI and publish use `direct` mode.

Longer rationale and the usrmerge / `--no-scripts` details for bootstrap
mode: see [`architecture.md`](architecture.md).
