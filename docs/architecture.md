# Architecture

The Dockerfile has two routes to a Wolfi runtime, selected via the
`BUILD_MODE` build-arg:

| Mode | Default? | FROM target | Use when |
| --- | --- | --- | --- |
| `direct` | yes | `${WOLFI_BASE}` (default `cgr.dev/chainguard/wolfi-base:latest`) | The Wolfi base registry is reachable. The canonical path. |
| `bootstrap` | no | `scratch` (rootfs built from `${BOOTSTRAP_IMAGE}` + apk-tools) | The Wolfi base registry is blocked. Self-contained fallback. |

Both produce a 100% Wolfi runtime. The runtime image in `direct` mode is
`FROM wolfi-base`; in `bootstrap` mode it's `FROM scratch` with a Wolfi
rootfs copied in. No Alpine binaries are in the runtime in either case.

CI and publish use `direct` mode against the public
`cgr.dev/chainguard/wolfi-base`. The rest of this document explains the
`bootstrap` mode's design — direct mode is the obvious one. Bootstrap exists
for environments where the public Chainguard base can't be pulled.

## Constraint 1: no chainguard/* base image

Some environments sit behind a container-registry allowlist that denies the
Chainguard images this runner would otherwise build `FROM`:

- `cgr.dev/chainguard/*` — can be blocked at the storage backend
  (`*.r2.cloudflarestorage.com`)
- `docker.io/chainguard/*` — can be blocked at the Docker Hub org level
  (`403 image access restricted: chainguard/wolfi-base blocked for
  organization <org>`)

When that's the case the conventional `FROM cgr.dev/chainguard/wolfi-base` is
unavailable, and so is its Docker Hub mirror. Bootstrap mode assembles the
Wolfi rootfs from the apk repository directly, so it works anyway.

## Constraint 2: keep it Wolfi

Wolfi's value over Alpine for an act runner is glibc. Most prebuilt action
binaries (`actions/setup-node`, `setup-python`, etc.) are linked against
glibc; running them on Alpine requires a `gcompat` shim that handles edge
cases badly. Wolfi is glibc-native and ships modern security defaults
(dynamic-only libraries, SBOM-attested packages, signed apk repo).

## Constraint 3: trust chain has to survive the workaround

We can't use Chainguard's signed image, but we *can* use Chainguard's signed
apk repository at `packages.wolfi.dev/os`. The repo and its signing key live
on the same domain (`packages.wolfi.dev`), so the TLS cert + signing key
fetched together establish the same trust chain a fresh
`FROM cgr.dev/chainguard/wolfi-base` would. No keys are vendored into the
repo — every build re-fetches the current signing key from
`https://packages.wolfi.dev/os/wolfi-signing.rsa.pub`.

## The bootstrap

The Dockerfile is two stages:

```
[bootstrap stage]                  [runtime stage]
FROM alpine                  ->    FROM scratch
  apk add apk-tools curl                 |
  configure /rootfs                      |
  apk add --root /rootfs                 v
    --initdb --no-scripts                COPY --from=bootstrap /rootfs/ /
    --keys-dir /etc/apk/keys
    --repositories-file /etc/apk/repositories
    wolfi-baselayout + everything else
```

Stage 1 starts from `docker.io/library/alpine:3.21` (allowed) and uses
**Alpine's** `apk-tools` to install **Wolfi's** packages into `/rootfs`.
That's possible because:

- The `.apk` format is the same across distributions.
- apk-tools operates on the target rootfs (`--root`), not its own libc, so
  it doesn't matter that Alpine is musl and Wolfi is glibc.
- We disable post-install scripts (`--no-scripts`) so Alpine's apk doesn't
  try to exec the Wolfi packages' glibc-linked install hooks. Wolfi
  packages ship pre-merged artifacts, so these hooks are runtime
  side-effects (e.g. updating a system-wide certificate hash list) that
  are safe to skip at build time.

Stage 2 is `FROM scratch` plus a `COPY` of the bootstrapped `/rootfs`. No
Alpine binaries leak into the final image.

### The usr-merge dance

Wolfi uses a usr-merged layout: `/bin`, `/sbin`, `/lib`, `/usr/sbin` are all
symlinks shipped by `wolfi-baselayout`. Alpine's `apk-tools --initdb`
defaults its database to `/lib/apk/db` and pre-creates `/lib` as a real
directory — which collides with `wolfi-baselayout`'s `/lib` symlink and
fails the extraction with `EISDIR` during rename.

We work around this by pre-creating `/rootfs/lib` ourselves as a symlink to
`usr/lib` before invoking `apk --initdb`. Then `--initdb` walks through the
symlink, ends up creating `/rootfs/usr/lib/apk` (which is fine), and
`wolfi-baselayout`'s `/lib` symlink installs over our pre-created identical
symlink without conflict.

We **do not** pre-create `/bin`, `/sbin`, or `/usr/sbin`, even though they're
also symlinks in `wolfi-baselayout`. Pre-creating them as directories blocks
the symlink extraction the same way. Pre-creating them as symlinks works
but isn't necessary — `--initdb` doesn't touch them, so we let
`wolfi-baselayout` define them.

The only directory we need to pre-create besides `/etc/apk/keys` is
`/rootfs/usr/lib`, so the `/lib → usr/lib` symlink resolves to an existing
target.

## What this doesn't do

- **No chroot.** apk runs from the host, writing into `/rootfs` directly.
  This is why `--no-scripts` is essential — chrooted scripts would work,
  but apk's chroot mode requires a working dynamic linker in the target
  and that's a chicken-and-egg problem during bootstrap.
- **No QEMU.** All apks are downloaded for the host architecture only.
  Multi-arch builds happen in the publish workflow via buildx (QEMU
  emulation across the target platforms), not inside this Dockerfile.
- **No layer optimization.** The bootstrap downloads ~1GB of apks in one
  shot and the final image inherits that as a single layer. Splitting
  buys nothing here because the entire rootfs is consumed by the
  `COPY --from=bootstrap` in stage 2.

## Why not apko

[`apko`](https://github.com/chainguard-dev/apko) is Chainguard's purpose-built
tool for exactly this kind of build, and it would be the right choice in an
environment where Chainguard images aren't blocked. But the apko binary itself
is distributed via cgr.dev and Docker Hub `chainguard/apko` — the same
registries an allowlisted environment blocks — so bootstrap mode would hit the
same wall trying to use it. The hand-rolled Alpine + apk bootstrap avoids that
bootstrap-of-a-bootstrap problem at the cost of about 30 lines of Dockerfile.
