# Maintenance

How to make changes safely.

## Switch CI/publish to bootstrap mode

CI tests both modes. Publish builds in the default `direct` mode (`FROM
cgr.dev/chainguard/wolfi-base`). If your fork runs in an environment that
can't pull `cgr.dev/chainguard/*`, force the self-contained bootstrap route
by adding a `build-args` entry:

1. In `.github/workflows/publish.yml`, set the build action input:

   ```yaml
   build-args: |
     BUILD_MODE=bootstrap
   ```

The Dockerfile default is `direct`. CI retains its two-mode matrix. See [`architecture.md`](architecture.md) for why bootstrap mode exists.

## Bump Node major version

1. Confirm the target version exists in Wolfi:

   ```bash
   curl -fsSL https://packages.wolfi.dev/os/x86_64/APKINDEX.tar.gz \
     | tar xzO APKINDEX | grep -E '^P:nodejs-[0-9]+$' | sort -u
   ```

2. Edit `Dockerfile`:

   ```text
   ARG NODE_MAJOR=22   →   ARG NODE_MAJOR=24
   ```

3. Edit `scripts/build.sh`:

   ```text
   NODE_MAJOR="${NODE_MAJOR:-22}"   →   NODE_MAJOR="${NODE_MAJOR:-24}"
   ```

4. Run the smoke locally:

   ```bash
   scripts/build.sh && scripts/test.sh
   ```

5. Open a PR. CI will rebuild + smoke against the new version.

## Bump Python minor version

Same procedure, but the variable is `PYTHON_MINOR` and the apk grep is:

```bash
curl -fsSL https://packages.wolfi.dev/os/x86_64/APKINDEX.tar.gz \
  | tar xzO APKINDEX | grep -E '^P:python-3\.[0-9]+$' | sort -u
```

Wolfi names Python packages by full minor (`python-3.13`), not major-only.

## Add a package

1. Verify the package exists:

   ```bash
   curl -fsSL https://packages.wolfi.dev/os/x86_64/APKINDEX.tar.gz \
     | tar xzO APKINDEX | grep -E '^P:<package-name>$'
   ```

2. Append it to **both** `apk add` lists in `Dockerfile` — the `variant-direct`
   stage and the `variant-bootstrap-builder` stage — grouped with the section
   that matches its purpose (shell, archive, crypto, build chain, etc.). The
   two lists must stay in sync so both build modes produce the same surface.
3. If the package is one that workflows reach for via `command -v`, also
   add it to the `for bin in ...` check in
   `.github/workflows/smoke.yml::shell-and-coreutils` so CI catches a
   future removal.

## Remove a package

Delete it from both `apk add` lists in `Dockerfile` (the `variant-direct` and
`variant-bootstrap-builder` stages). If it was being smoke-tested, remove the
corresponding check from `smoke.yml`.

## Bump the Alpine bootstrap base

The bootstrap base only matters for stage 1; nothing from Alpine reaches the
final image. Dependabot will open a PR when a new Alpine minor lands. To
do it by hand:

1. Edit `Dockerfile`:

   ```text
   ARG BOOTSTRAP_IMAGE=docker.io/library/alpine:3.21   →   ARG BOOTSTRAP_IMAGE=docker.io/library/alpine:3.22
   ```

2. Edit `scripts/build.sh` to match.
3. CI smokes the change.

If a future Alpine release breaks the bootstrap (apk-tools incompatibility,
removed package, etc.), pin to the last known-good tag and file a follow-up.

## Pick up Wolfi package drift

The publish workflow runs every Sunday 09:00 UTC and republishes the image
even if no source changed, because the underlying Wolfi packages may have
moved. The republished image gets a fresh date-stamped tag and supersedes
`:latest` only if the digest changed. To trigger ad-hoc:

```bash
gh workflow run publish.yml
```

## Verify a published image

Cosign keyless signature (issued via GitHub OIDC, identity tied to this
repo's publish workflow):

```bash
cosign verify \
  --certificate-identity-regexp "^https://github.com/smeltery/kiln/.*$" \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  ghcr.io/smeltery/kiln:<tag>
```

SBOM + provenance attestation (attached by BuildKit during the build):

```bash
# SBOM
docker buildx imagetools inspect \
  ghcr.io/smeltery/kiln:<tag> \
  --format '{{ json .SBOM }}'

# Provenance
docker buildx imagetools inspect \
  ghcr.io/smeltery/kiln:<tag> \
  --format '{{ json .Provenance }}'
```

## Adjust what publish.yml publishes

The image name is derived from `${{ github.repository }}` and pushed to
`ghcr.io/<owner>/kiln` — no hardcoded registry path to change if
the repo is renamed or transferred.

Schedule, tag triggers, which branches publish, the target platforms
(`linux/amd64,linux/arm64`), and the cosign signing step all live in
`.github/workflows/publish.yml`. It's self-contained — there's no external
reusable workflow to track.

## Add a CI lint

Add the check to `scripts/check.sh` so CI and pre-commit both run it.
Declare native tools in Flox and JavaScript tools in `package.json`. SHA-pin the
action and include the tag as a trailing comment so dependabot can update
both at once:

```yaml
- name: <lint name>
  uses: owner/action@<sha>   # vX.Y.Z
```

## Run an act test of a workflow locally

```bash
tests/act/run-workflows.sh
```

This actionlints all workflows and runs `act --list` on the ones that
don't reference external reusable workflows (act can't resolve those).
