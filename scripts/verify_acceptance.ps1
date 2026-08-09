[CmdletBinding()]
param(
  [switch]$SkipUpdate
)

$ErrorActionPreference = "Stop"

function Invoke-QualityGate {
  param(
    [string]$Name,
    [scriptblock]$Command
  )

  Write-Host "==> $Name"
  & $Command
  if ($LASTEXITCODE -ne 0) {
    throw "Quality gate failed: $Name (exit code $LASTEXITCODE)"
  }
}

if ($SkipUpdate) {
  Write-Host "==> Skipping moon update"
} else {
  Invoke-QualityGate "moon update" { moon update }
}

Invoke-QualityGate "moon version --all" { moon version --all }
Invoke-QualityGate "moon fmt --check" { moon fmt --check }
Invoke-QualityGate "moon check --deny-warn --target all" { moon check --deny-warn --target all }
Invoke-QualityGate "moon build --target wasm,wasm-gc,js" { moon build --target wasm,wasm-gc,js }
Invoke-QualityGate "moon info --target all" { moon info --target all }
Invoke-QualityGate "git diff --ignore-blank-lines --exit-code" { git diff --ignore-blank-lines --exit-code }
Invoke-QualityGate "moon test --deny-warn --target wasm,wasm-gc,js" { moon test --deny-warn --target wasm,wasm-gc,js }
Invoke-QualityGate "moon build --target native" { moon build --target native }
Invoke-QualityGate "moon test --deny-warn --target native" { moon test --deny-warn --target native }
