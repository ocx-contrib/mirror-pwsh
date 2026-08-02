# mirror-powershell

OCX mirror for [PowerShell](https://github.com/PowerShell/PowerShell). One
repository, one spec directory per package.

| Package | Spec | Publishes to | Announced as | Upstream SPDX |
|---|---|---|---|---|
| [PowerShell](https://github.com/PowerShell/PowerShell) | [`powershell/mirror.yml`](powershell/mirror.yml) | `ghcr.io/ocx-contrib/powershell/powershell` | `ocx.sh/powershell/powershell` | `MIT` |

Each upstream release is discovered, re-bundled, smoke-tested per
`(version, platform)` and only then pushed with cascade tags, after which the
result is announced into the OCX index.

> This repository previously published the same upstream to the flat coordinate
> `ocx.sh/pwsh` (and was itself named `mirror-pwsh`).
> `powershell/powershell` is the grouped successor. The package segment is the
> name the project publishes under, not the binary you type — upstream is
> `PowerShell/PowerShell` and ships `pwsh`, the same relationship as
> `github/cli` shipping `gh`.

## Layout

```
mirror-base.yml         repo-wide policy every spec inherits via `extends:`
powershell/
├── mirror.yml          the spec — never at the repo root
├── metadata.json       bundle interface
├── CATALOG.md          → ocx package describe
├── logo.svg / logo.png describe assets, 512px PNG
└── tests/smoke.star    Starlark smoke test
```

`LICENSE` and `NOTICE.md` are shared at the root. Logos are **not** — each
package carries its own, because a repo-root `logo.*` sits in no workflow's
`paths:` filter, so replacing it would publish nothing until some unrelated
edit happened to fire.

⚠️ `extends:` is a **shallow** merge of top-level keys. A spec that restates
`platforms:` to change one runner drops every `containers:` entry with it, and
nothing reds — the legs simply stop existing, and every `os.features` claim
goes back to being asserted rather than verified. Restate a block in full or
not at all.

## Platforms

Six entries: both Linux arches (glibc), both macOS arches and both Windows
arches. `pwsh` is a self-contained .NET application, so no build here is
static — each Linux binary names its own loader in `PT_INTERP` — and the Linux
keys therefore carry an explicit `+libc.glibc` feature rather than a bare key,
which would falsely claim libc universality. The measurements are recorded
above `powershell/mirror.yml`'s `assets:` block.

**The container legs are Microsoft's `dotnet/runtime-deps` images, not bare
distro bases.** `pwsh` needs `libicu` at process start, which `ubuntu:24.04`,
`fedora:40`, `debian:12`, `rockylinux:9`, `almalinux:9` and `opensuse/leap` all
lack, and `containers[]` accepts only `image` and `shell` — there is no setup
hook in which to install it. `runtime-deps` is precisely "the minimal host a
self-contained .NET app needs", so it is the honest image to prove the claim in.

**No `+libc.musl` entry, and that is a tooling limitation rather than a
preference.** Upstream does ship `powershell-<v>-linux-musl-x64.tar.gz` (amd64
only). A musl payload cannot run natively on the glibc runner, so its leg must
be a container — but the renderer infers a container's libc from the image
*basename* alone (`infer_libc_from_image`: only `alpine*` counts as musl). The
one musl image that actually works,
`mcr.microsoft.com/dotnet/runtime-deps:9.0-alpine3.21`, is read as glibc and
rejected at spec load, while the accepted bare `alpine:3.20` cannot load the
artifact at all (it ships neither `libstdc++` nor `icu-libs`). Restore the key
once `ocx-mirror` grows `containers[].libc` or a per-container setup hook.

Upstream also publishes `linux-arm32`, `win-x86`, the `fxdependent` variants
(which need a preinstalled .NET SDK), the `.deb`/`.rpm`/`.pkg`/`.msi`
installers and the `powershell-lts-*` republished channel. None are mirrored;
the anchored `^…$` asset regexes are what keep them out.

## Editing

| File | Edit | Regenerate after |
|------|------|------------------|
| `mirror-base.yml`, `powershell/mirror.yml` | hand | yes — see below |
| `powershell/{metadata.json,CATALOG.md,logo.*}` | hand | — |
| `powershell/tests/smoke.star` | hand | — |
| `.github/workflows/*.yml` | **generated — never hand-edit** | re-run when a spec changes |

```bash
ocx-mirror package pipeline generate ci --spec powershell/mirror.yml
```

**Name every spec.** `--spec` *appends* rather than replaces, so a command
naming a subset silently stops rendering the rest while staying green — and the
drift guard reds on a generated workflow the current spec set no longer
produces.

`verify-generated.yml` exits 65 on drift. If a generated workflow is wrong, the
spec or the renderer template is wrong — fix it there and regenerate.

Run `direnv allow` once to put the pinned toolchain on `PATH`, and invoke
`ocx-mirror` directly — never `ocx run -- ocx-mirror`, which pins
`OCX_BINARY_PIN` to the bootstrap `ocx` and false-reds the nested push.

## The binaries claim

Every upstream archive extracts **flat at its root** — `pwsh`, `createdump` and
~725 sibling `*.dll`/`*.so` files, with no `bin/` directory — so the bundle's
only PATH entry is a bare `${installPath}`. `bin_scan` only looks *below* an
`${installPath}/<dir>` entry, so `auto`/`verify` is rejected at spec load with
exit 65. `mirror-base.yml` therefore sets `bin_scan: off` and
`powershell/metadata.json` hand-lists `binaries: ["createdump", "pwsh"]`.

`createdump` is listed because it is genuinely there: it carries the exec bit
at the archive root on all six platforms and lands on the consumer's `PATH`
next to `pwsh`. Declaring only `pwsh` would understate the interface surface,
which the claim exists to describe honestly.

## Required secrets

| Secret | Use |
|--------|-----|
| `OCX_ANNOUNCE_TOKEN` | opens the index pull request from the `ocx-contrib/index` fork |
| `OCX_MIRROR_DISCORD_HOOK` | notify-stage Discord webhook URL |

(Inherited from the `ocx-contrib` org with visibility ALL. GHCR pushes use the
run's own `GITHUB_TOKEN` — no registry secret needed.)

## License

Apache-2.0 — see [`LICENSE`](LICENSE). Upstream assets are out of scope; each
package's redistribution license is recorded in [`NOTICE.md`](NOTICE.md).
