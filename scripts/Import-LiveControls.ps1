#Requires -Version 7.0
<#
.SYNOPSIS
Backs up SPT controls and imports Control.ini from live Tarkov.
.EXAMPLE
./scripts/Import-LiveControls.ps1 -GamePath 'C:\sptarkov\SPTarkov 5.0.0-BE-1.3.0.0.48484' -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$GamePath,
    [string]$LiveControls = (Join-Path $env:APPDATA 'Battlestate Games\Escape from Tarkov\Settings\Control.ini')
)

$ErrorActionPreference = 'Stop'
if (Get-Process EscapeFromTarkov -ErrorAction SilentlyContinue) {
    throw 'Close the Tarkov client before importing controls.'
}
$source = (Resolve-Path -LiteralPath $LiveControls).Path
$runtime = (Resolve-Path -LiteralPath (Join-Path $GamePath 'SPT_Runtime')).Path
$destination = Join-Path $runtime 'user\sptSettings\Control.ini'
if (-not (Test-Path -LiteralPath $destination -PathType Leaf)) {
    throw "Existing SPT controls were not found: $destination"
}
if ([string]::Equals($source, $destination, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Source and destination must be different files.'
}
foreach ($path in @($source, $destination)) {
    $controls = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    foreach ($field in @('Version', 'axisBindings', 'keyBindings')) {
        if ($controls.PSObject.Properties.Name -notcontains $field) {
            throw "Missing controls field '$field' in $path"
        }
    }
}

if ($PSCmdlet.ShouldProcess($destination, "Back up controls and import $source")) {
    $backupDir = Join-Path $runtime ('user\migration-backups\controls-' + (Get-Date -Format 'yyyyMMdd-HHmmss-fffffff'))
    New-Item -ItemType Directory -Path $backupDir | Out-Null
    $backup = Join-Path $backupDir 'Control.ini'
    Copy-Item -LiteralPath $destination -Destination $backup
    $expectedHash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
    try {
        Copy-Item -LiteralPath $source -Destination $destination
        if ((Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash -ne $expectedHash) {
            throw 'Imported controls failed SHA-256 verification.'
        }
    }
    catch {
        Copy-Item -LiteralPath $backup -Destination $destination
        throw
    }
    [pscustomobject]@{ Source = $source; Destination = $destination; Backup = $backup; SHA256 = $expectedHash }
}
