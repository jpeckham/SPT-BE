#Requires -Version 7.0
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][ValidateSet('Server','Client')][string]$Kind,
    [Parameter(Mandatory)][string]$GamePath,
    [Parameter(Mandatory)][string]$OutputDirectory,
    [string]$ProfileId
)
$ErrorActionPreference = 'Stop'
$game = (Resolve-Path -LiteralPath $GamePath).Path
$runtime = Join-Path $game 'SPT_Runtime'
$exe = if ($Kind -eq 'Server') { Join-Path $runtime 'SPT.Server.exe' } else { Join-Path $game 'EscapeFromTarkov.exe' }
if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) { throw "Executable missing: $exe" }
$processName = [IO.Path]::GetFileNameWithoutExtension($exe)
if (Get-Process -Name $processName -ErrorAction SilentlyContinue) { throw "$processName is already running; it will not be replaced." }
if ($Kind -eq 'Client') {
    if ($ProfileId -notmatch '^[a-f0-9]{24}$') { throw 'Provide a valid test ProfileId.' }
    $profile = Get-Content -LiteralPath (Join-Path $runtime "user/profiles/$ProfileId.json") -Raw | ConvertFrom-Json
    if ($profile.info.username -notlike 'LocalBuildTest*') { throw 'Use a LocalBuildTest account for automated smoke checks.' }
    if (-not (Get-Process -Name SPT.Server -ErrorAction SilentlyContinue | Where-Object Path -EQ (Join-Path $runtime 'SPT.Server.exe'))) {
        throw 'Start this installation server first and wait until its log says it is ready.'
    }
}
if ($PSCmdlet.ShouldProcess($exe, "Start $Kind smoke process")) {
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
    $output = (Resolve-Path -LiteralPath $OutputDirectory).Path
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss-fffffff'
    $prefix = Join-Path $output "$($Kind.ToLower())-$stamp"
    $options = @{ FilePath=$exe; WindowStyle='Hidden'; PassThru=$true }
    if ($Kind -eq 'Server') {
        $options.WorkingDirectory=$runtime
        $options.RedirectStandardOutput="$prefix.log"
        $options.RedirectStandardError="$prefix-error.log"
    } else {
        $options.WorkingDirectory=$game
        $options.ArgumentList=@('-force-gfx-jobs','native',"-token=$ProfileId",
            "-config={'BackendUrl':'https://127.0.0.1:6969','Version':'live','MatchingVersion':'live'}",'-logFile',"`"$prefix-unity.log`"")
    }
    $process = Start-Process @options
    $state = [ordered]@{ Kind=$Kind; Pid=$process.Id; Executable=$exe; StartTimeUtcTicks=$process.StartTime.ToUniversalTime().Ticks; LogPrefix=$prefix }
    $statePath="$prefix-process.json"
    $state | ConvertTo-Json | Set-Content -LiteralPath $statePath
    [pscustomobject]@{ StateFile=$statePath; Pid=$process.Id; LogPrefix=$prefix }
}
