# NOTICE

This repository packages and redistributes upstream software published by
[Microsoft](https://github.com/PowerShell). The Apache-2.0 license in
[`LICENSE`](LICENSE) covers the OCX pipeline files authored here. It does
**not** cover any upstream-derived asset — each package's redistributed bytes
carry their own license, recorded below.

Each package's logo is reproduced for catalog identification only, under
nominative fair use. The marks remain the property of their respective owners
and no endorsement is implied.

| Package | GHCR path | Upstream SPDX |
|---|---|---|
| `powershell` | `ghcr.io/ocx-contrib/powershell/powershell` | `MIT` |

---

## `powershell`

Upstream: <https://github.com/PowerShell/PowerShell>
Published to `ghcr.io/ocx-contrib/powershell/powershell`.

| Component | SPDX | Holder |
|---|---|---|
| PowerShell (`pwsh`, `createdump`, bundled .NET runtime) | **MIT** | Copyright (c) Microsoft Corporation |

Permissive; redistribution of the compiled binaries is granted provided the
copyright notice and permission notice are retained. The terms are those of
<https://github.com/PowerShell/PowerShell/blob/master/LICENSE.txt>, and every
mirrored archive ships that notice as `LICENSE.txt` at its own root, so it
travels with the bytes. The published payload is self-contained and statically
embeds the .NET runtime and a set of third-party assemblies under permissive
licenses, enumerated in upstream's `ThirdPartyNotices.txt`.

PowerShell is a trademark of Microsoft Corporation. The name and logo are used
for catalog identification under nominative fair use.

No modifications are made to any upstream artifact in this repository; they are
republished byte-for-byte inside an OCX bundle.
