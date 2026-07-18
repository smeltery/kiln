# What's in the image

| Category   | Contents                                                                 |
| ---------- | ------------------------------------------------------------------------ |
| Shell      | `bash`, `busybox`, GNU coreutils/findutils/grep/sed/gawk, diffutils      |
| Network    | `curl`, `wget`, `openssh-client`, `rsync`                                |
| Archive    | `gnutar`, `gzip`, `bzip2`, `xz`, `zstd`, `unzip`, `zip`                  |
| Crypto     | `gnupg`, `openssl`, `ca-certificates-bundle`                             |
| Data       | `jq`, `yq`                                                               |
| VCS        | `git`, `git-lfs`, `patch`                                                |
| Build      | `build-base` (gcc/g++/make/binutils/glibc-dev), `libstdc++`              |
| Runtimes   | `nodejs-22`, `npm`, `python-3.13`, `py3-pip`                             |
| Container  | `docker-cli`, `docker-cli-buildx`, `docker-compose` (daemon from socket) |
| Privilege  | `sudo` with passwordless config for the `runner` user                    |
| GitHub CLI | `gh`                                                                     |

The runner user (`runner`, uid auto) is in the `docker` group and has
passwordless sudo, matching the GitHub-hosted runner conventions.

Adding or removing a package: see [`maintenance.md`](maintenance.md).
