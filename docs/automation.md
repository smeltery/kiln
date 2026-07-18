# Automation surface

| Workflow                                       | Trigger                                                       | What it does                                                       |
| ---------------------------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------------ |
| [`ci.yml`](../.github/workflows/ci.yml)           | PR + push to main                                             | hadolint / actionlint / shellcheck, then build + act smoke         |
| [`publish.yml`](../.github/workflows/publish.yml) | push to main, `v*` tag, weekly cron (Sun 09:00 UTC), manual   | Multi-arch build + push to GHCR, cosign keyless signing, SBOM      |
| [`pr-validation.yml`](../.github/workflows/pr-validation.yml) | PR opened/edited/synchronized                       | Conventional-commits title check                                   |
| [`smoke.yml`](../.github/workflows/smoke.yml)     | Not run on GitHub directly — invoked by CI and `scripts/test.sh` via act | Tests the runtime image surface                          |

[`dependabot.yml`](../.github/dependabot.yml) opens weekly PRs for GH Actions
pin updates and the Alpine bootstrap base.

Tuning what publish.yml publishes, adding a CI lint, and running an act test
of a workflow locally: see [`maintenance.md`](maintenance.md).
