# Stable smoke test — assert on the contract (exit code, version shape,
# computed results), never on help/version prose or banners. PowerShell reworks
# its copyright/banner text freely; the PSVersion digits, the value of a pure
# expression and the .NET type a cmdlet returns are the contract.
#
# Every invocation is `-NoProfile` AND runs with HOME / XDG_* pointed at the
# scratch sandbox, so no user or machine profile, module path or history file
# can reach the session — on a developer box that would otherwise make the
# result depend on whatever is in ~/.config/powershell.

PWSH = "pwsh.exe" if ocx.target_platform.os == ocx.os.Windows else "pwsh"

# PATH / OCX_* are reserved and cannot be overlaid; HOME and the XDG vars are
# not. POWERSHELL_TELEMETRY_OPTOUT keeps the test hermetic — pwsh otherwise
# phones home on start, which is network I/O inside a container leg.
ENV = {
    "HOME": ocx.scratch_root,
    "USERPROFILE": ocx.scratch_root,
    "XDG_CONFIG_HOME": ocx.scratch_root + "/xdg-config",
    "XDG_DATA_HOME": ocx.scratch_root + "/xdg-data",
    "XDG_CACHE_HOME": ocx.scratch_root + "/xdg-cache",
    "POWERSHELL_TELEMETRY_OPTOUT": "1",
}

# Tier 1 + 2: liveness + version SHAPE. $PSVersionTable.PSVersion is the engine
# version object; .ToString() yields semver digits — a stable signal that
# exercises real engine init (stronger than a banner/--version short-circuit).
r_version = ocx.run(
    PWSH, "-NoProfile", "-NoLogo", "-Command", "$PSVersionTable.PSVersion.ToString()",
    env = ENV,
)
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")

# Tier 3a: functional behavior. A pure arithmetic expression runs the parser and
# the evaluator end to end and prints the computed result — assert the value,
# not any prose. No filesystem, no network: fully hermetic.
r_eval = ocx.run(PWSH, "-NoProfile", "-NoLogo", "-Command", "2 + 2", env = ENV)
expect.ok(r_eval)
expect.contains(r_eval.stdout, "4")

# Tier 3b: a real cmdlet plus the .NET type system underneath it. Get-Date is
# resolved out of the shipped Microsoft.PowerShell.Commands.Utility.dll and must
# hand back a System.DateTime — this fails on a bundle whose sibling assemblies
# did not survive extraction, which the arithmetic above would not catch.
r_cmdlet = ocx.run(
    PWSH, "-NoProfile", "-NoLogo", "-Command", "(Get-Date).GetType().Name",
    env = ENV,
)
expect.ok(r_cmdlet)
expect.contains(r_cmdlet.stdout, "DateTime")
