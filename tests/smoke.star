# Stable smoke test — assert on the contract (exit code, version shape,
# computed result), never on help/version prose or banners. PowerShell reworks
# its copyright/banner text freely; the PSVersion digits and the result of a
# pure expression are the contract.
PWSH = "pwsh.exe" if ocx.target_platform.os == ocx.os.Windows else "pwsh"

# Tier 1 + 2: liveness + version SHAPE. $PSVersionTable.PSVersion is the engine
# version object; .ToString() yields semver digits — a stable signal that
# exercises real engine init (stronger than a banner/--version short-circuit).
r_version = ocx.run(PWSH, "-NoLogo", "-Command", "$PSVersionTable.PSVersion.ToString()")
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")

# Tier 3: functional behavior. A pure arithmetic expression runs the parser and
# evaluator end to end and prints the computed result — assert the value, not
# any prose. No filesystem, no network: fully hermetic.
r_eval = ocx.run(PWSH, "-NoLogo", "-Command", "1 + 1")
expect.ok(r_eval)
expect.contains(r_eval.stdout, "2")
