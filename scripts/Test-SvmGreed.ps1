param(
    [Parameter(Mandatory)][string]$GamePath,
    [Parameter(Mandatory)][string]$OutputDirectory
)
$ErrorActionPreference = 'Stop'
if (Get-Process Greed -ErrorAction SilentlyContinue) { throw 'Close Greed before this startup check.' }
$game = (Resolve-Path -LiteralPath $GamePath).Path
$exe = Join-Path $game 'Greed.exe'
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$record = Join-Path $OutputDirectory ('greed-' + (Get-Date -Format yyyyMMdd-HHmmss) + '.json')
$process = Start-Process -FilePath $exe -WorkingDirectory $game -WindowStyle Hidden -PassThru
$ticks = $process.StartTime.ToUniversalTime().Ticks
try {
    Start-Sleep -Seconds 3
    $process.Refresh()
    if ($process.HasExited) { throw 'Greed exited during startup.' }
    $result = [ordered]@{ Pid=$process.Id; Path=$exe; StartTicks=$ticks; Responding=$process.Responding; Title=$process.MainWindowTitle }
    $result | ConvertTo-Json | Set-Content -LiteralPath $record
    if (!$process.Responding -or $process.MainWindowTitle -ne 'Greed') { throw 'Greed did not reach its main window.' }
    Write-Output "PASS: Greed main window responds. Evidence: $record. UI settings were not exercised."
} finally {
    $current = Get-Process -Id $process.Id -ErrorAction SilentlyContinue
    if ($current -and $current.Path -eq $exe -and $current.StartTime.ToUniversalTime().Ticks -eq $ticks) {
        $null = $current.CloseMainWindow()
        if (!$current.WaitForExit(3000)) { $current.Kill() }
    }
}
