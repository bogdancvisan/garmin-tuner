param([string]$Device = "fenix847mm")
# Requires $env:CIQ_SDK_HOME and $env:DEVELOPER_KEY (.der)
$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")
if (-not $env:CIQ_SDK_HOME) { throw "Set CIQ_SDK_HOME to the Connect IQ SDK root" }
if (-not $env:DEVELOPER_KEY) { throw "Set DEVELOPER_KEY to your developer key (.der)" }
New-Item -ItemType Directory -Force bin | Out-Null
& "$env:CIQ_SDK_HOME\bin\monkeyc.bat" -d $Device -f monkey.jungle -o "bin\GarminTuner-$Device.prg" -y $env:DEVELOPER_KEY -w
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "Built bin\GarminTuner-$Device.prg"
