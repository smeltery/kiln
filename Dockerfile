# syntax=docker/dockerfile:1.7
#
# kiln — a Chainguard Wolfi-based runner image for nektos/act.
#
# Drop-in replacement for catthehacker/ubuntu:act-latest (act-medium tier).
# Wolfi is glibc-based, so prebuilt action binaries work without a gcompat
# shim. The package set matches what most workflows expect from ubuntu-latest:
# shell, coreutils, build chain, node, python, docker CLI, gh, archive +
# crypto + network utilities.
#
# Two build modes select the route to a Wolfi rootfs:
#
#   direct (default)     FROM ${WOLFI_BASE}; apk add packages on top. Use
#                        when the registry hosting WOLFI_BASE is reachable.
#                        This is the canonical path.
#
#   bootstrap (fallback) FROM ${BOOTSTRAP_IMAGE} (alpine); use that image's
#                        apk-tools to install Wolfi packages from
#                        packages.wolfi.dev/os into /rootfs, then start the
#                        final image FROM scratch and COPY /rootfs in. Use
#                        when WOLFI_BASE is blocked by registry policy
#                        (e.g. allowlisted/air-gapped environments that can't
#                        pull cgr.dev/chainguard images).
#
# Both modes produce a 100% Wolfi runtime. In direct mode the runtime stage
# is `FROM wolfi-base`; in bootstrap mode it's `FROM scratch` with a Wolfi
# rootfs copied in. No Alpine binaries are in the runtime in either case.
#
# Select via --build-arg BUILD_MODE=direct|bootstrap

ARG BUILD_MODE=direct
ARG WOLFI_BASE=cgr.dev/chainguard/wolfi-base:latest
ARG BOOTSTRAP_IMAGE=docker.io/library/alpine:3.21
ARG NODE_MAJOR=22
ARG PYTHON_MINOR=3.13
ARG WOLFI_REPO=https://packages.wolfi.dev/os
ARG WOLFI_KEY_URL=https://packages.wolfi.dev/os/wolfi-signing.rsa.pub

# =============================================================================
# Direct variant — FROM Wolfi, apk add packages on top.
# =============================================================================
FROM ${WOLFI_BASE} AS variant-direct

ARG NODE_MAJOR
ARG PYTHON_MINOR

USER root

# Keep this package list in sync with the bootstrap variant's `apk add` below.
RUN apk add --no-cache \
      bash \
      busybox \
      coreutils \
      findutils \
      grep \
      sed \
      gawk \
      diffutils \
      file \
      less \
      ncurses \
      procps \
      psmisc \
      shadow \
      tzdata \
      ca-certificates-bundle \
      gnupg \
      gpg \
      openssl \
      curl \
      wget \
      openssh-client \
      rsync \
      gnutar \
      gzip \
      bzip2 \
      xz \
      zstd \
      unzip \
      zip \
      jq \
      yq \
      git \
      git-lfs \
      patch \
      build-base \
      libstdc++ \
      nodejs-${NODE_MAJOR} \
      npm \
      python-${PYTHON_MINOR} \
      py3-pip \
      sudo \
      docker-cli \
      docker-cli-buildx \
      docker-compose \
      gh

# =============================================================================
# Bootstrap variant — alpine-driven apk install into /rootfs, then scratch.
# =============================================================================
#
# Wolfi uses a usr-merged layout: /lib, /bin, /sbin, /usr/sbin are symlinks
# shipped by wolfi-baselayout. Alpine's apk-tools --initdb defaults its db
# to /lib/apk/db and would allocate /lib as a real directory, colliding
# with wolfi-baselayout's /lib symlink at EISDIR rename. We pre-create
# /rootfs/lib as the symlink so --initdb walks through it.
#
# --no-scripts skips post-install hooks because alpine's apk runs them on
# the host (no chroot), and Wolfi's glibc post-install binaries can't exec
# under alpine's musl. Wolfi packages ship pre-merged artifacts, so these
# hooks are runtime-side-effects safe to skip at build.
FROM ${BOOTSTRAP_IMAGE} AS variant-bootstrap-builder

ARG NODE_MAJOR
ARG PYTHON_MINOR
ARG WOLFI_REPO
ARG WOLFI_KEY_URL

RUN apk add --no-cache apk-tools ca-certificates curl

RUN set -eux; \
    mkdir -p /etc/apk/keys; \
    curl -fsSL "$WOLFI_KEY_URL" -o /etc/apk/keys/wolfi-signing.rsa.pub; \
    mkdir -p /rootfs/etc/apk/keys /rootfs/usr/lib; \
    ln -s usr/lib /rootfs/lib; \
    cp /etc/apk/keys/wolfi-signing.rsa.pub /rootfs/etc/apk/keys/; \
    echo "$WOLFI_REPO" > /etc/apk/repositories; \
    apk add \
        --root /rootfs \
        --initdb \
        --no-scripts \
        --no-cache \
        --keys-dir /etc/apk/keys \
        --repositories-file /etc/apk/repositories \
        wolfi-baselayout \
        apk-tools \
        bash busybox coreutils findutils grep sed gawk diffutils file less \
        ncurses procps psmisc shadow tzdata \
        ca-certificates-bundle gnupg gpg openssl \
        curl wget openssh-client rsync \
        gnutar gzip bzip2 xz zstd unzip zip \
        jq yq \
        git git-lfs patch \
        build-base libstdc++ \
        nodejs-${NODE_MAJOR} npm \
        python-${PYTHON_MINOR} py3-pip \
        sudo \
        docker-cli docker-cli-buildx docker-compose \
        gh; \
    cp /etc/apk/repositories /rootfs/etc/apk/repositories; \
    rm -rf /rootfs/var/cache/apk/* /rootfs/tmp/*

FROM scratch AS variant-bootstrap

COPY --from=variant-bootstrap-builder /rootfs/ /

# =============================================================================
# Final stage — select variant, then layer runner conventions on top.
# =============================================================================
FROM variant-${BUILD_MODE} AS final

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# wolfi-baselayout's post-install script (skipped via --no-scripts in the
# bootstrap variant) is responsible for setting up /bin/sh → busybox and a
# few other shell wiring symlinks. Recreate them here so they're present in
# both variants and we don't depend on cross-libc post-install execution.
# Without this, scripts with `#!/bin/sh` (e.g. /usr/local/bin/gcc from
# posix-cc-wrappers) fail with "bad interpreter".
RUN [ -e /usr/bin/sh ]     || ln -sf /usr/bin/busybox /usr/bin/sh; \
    [ -e /usr/bin/awk ]    || ln -sf /usr/bin/gawk /usr/bin/awk; \
    [ -e /usr/bin/zstdmt ] || ln -sf /usr/bin/zstd /usr/bin/zstdmt

# Symlink node/npm/npx into /usr/local/bin so action toolcache shims that
# hardcode that path resolve correctly.
RUN [ -e /usr/local/bin/node ] || ln -sf "$(command -v node)" /usr/local/bin/node; \
    [ -e /usr/local/bin/npm  ] || ln -sf "$(command -v npm)"  /usr/local/bin/npm;  \
    [ -e /usr/local/bin/npx  ] || ln -sf "$(command -v npx)"  /usr/local/bin/npx

# Non-root runner user with passwordless sudo, mirroring the ubuntu runner
# image conventions. act execs steps as root by default, but actions that
# drop to a `runner` user or use `sudo` expect this setup.
RUN groupadd --system runner; \
    useradd --system --gid runner --create-home --shell /bin/bash runner; \
    groupadd --system docker || true; \
    usermod -aG docker runner; \
    echo 'runner ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/runner; \
    chmod 0440 /etc/sudoers.d/runner

# Identify as Wolfi but advertise ID_LIKE=debian/ubuntu so distro-sniffing
# actions take a compatible code path.
RUN { \
      echo 'NAME="Wolfi"'; \
      echo 'ID=wolfi'; \
      echo 'ID_LIKE="debian ubuntu"'; \
      echo 'PRETTY_NAME="Wolfi (act runner)"'; \
      echo 'HOME_URL="https://wolfi.dev"'; \
    } > /etc/os-release

LABEL org.opencontainers.image.base.name="wolfi (runtime)"
LABEL org.opencontainers.image.title="kiln"
LABEL org.opencontainers.image.description="Wolfi-based runner image for nektos/act"
LABEL org.opencontainers.image.source="https://github.com/dotbrains/kiln"
LABEL org.opencontainers.image.licenses="PolyForm-Shield-1.0.0"

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    RUNNER_TOOL_CACHE=/opt/hostedtoolcache \
    AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache \
    ImageOS=wolfi

RUN mkdir -p "$RUNNER_TOOL_CACHE" && chmod 0777 "$RUNNER_TOOL_CACHE"

WORKDIR /workspace

# No ENTRYPOINT / CMD: act injects `tail -f /dev/null` and execs steps.
