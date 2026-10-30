#Requires -Version 7.0
[CmdletBinding(SupportsShouldProcess)]
param([Parameter(Mandatory)][string]$StateFile, [switch]$Force)
$ErrorActionPreference='Stop'
$state=Get-Content -LiteralPath $StateFile -Raw | ConvertFrom-Json
$process=Get-Process -Id $state.Pid -ErrorAction SilentlyContinue
if (-not $process) { Write-Output 'Smoke process already stopped.'; return }
if ($process.Path -ne $state.Executable -or $process.StartTime.ToUniversalTime().Ticks -ne $state.StartTimeUtcTicks) {
    throw 'Process identity no longer matches the recorded smoke process; refusing to stop it.'
}
if ($PSCmdlet.ShouldProcess("$($process.Path) (PID $($process.Id))", 'Stop recorded smoke process')) {
    if ($process.MainWindowHandle -ne 0) {
        [void]$process.CloseMainWindow()
        if ($process.WaitForExit(5000)) { return }
    }
    if (-not $Force) { throw 'Process did not close gracefully. Use -Force to terminate this verified smoke process.' }
    Stop-Process -Id $process.Id
    $process.WaitForExit()
}
