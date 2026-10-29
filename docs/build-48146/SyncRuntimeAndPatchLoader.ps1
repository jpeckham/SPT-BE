$ErrorActionPreference = "Stop"

# 1. Copy newly built BepInXDX & Il2CppInterop files into bento/assets/il2cpp/BepInEx/core/
Copy-Item "c:\Users\james\source\repos\SP-Tushonka\BepInXDX\bin\Unity.IL2CPP\*" "c:\Users\james\source\repos\SP-Tushonka\bento\assets\il2cpp\BepInEx\core\" -Force
Write-Host "Copied BepInXDX/bin/Unity.IL2CPP/* into bento/assets/il2cpp/BepInEx/core/"

# 2. Extract version.dll from bento 53a48e6:assets/il2cpp/version.dll and patch for 48146
$versionDllPath = "c:\Users\james\source\repos\SP-Tushonka\bento\assets\il2cpp\version.dll"
git -C "c:\Users\james\source\repos\SP-Tushonka\bento" show 53a48e6:assets/il2cpp/version.dll > $null

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "git"
$psi.Arguments = "-C `"c:\Users\james\source\repos\SP-Tushonka\bento`" cat-file blob 53a48e6:assets/il2cpp/version.dll"
$psi.RedirectStandardOutput = $true
$psi.UseShellExecute = $false
$proc = [System.Diagnostics.Process]::Start($psi)
$ms = New-Object System.IO.MemoryStream
$proc.StandardOutput.BaseStream.CopyTo($ms)
$proc.WaitForExit()
$bytes = $ms.ToArray()

Write-Host "Extracted version.dll size: $($bytes.Length) bytes"

# Verify original bytes at file offset 0x1E9A (RVA 0x2A9A):
# 41 81 F9 B7 97 C3 6A (cmp r9d, 0x6AC397B7)
# 75 2B                (jne ...)
# 3D 00 60 72 06       (cmp eax, 0x06726000)
$origSlice = ($bytes[0x1E9A..0x1EA7] | ForEach-Object { $_.ToString("X2") }) -join " "
Write-Host "Original bytes at 0x1E9A..0x1EA7: $origSlice"

$oldTs = [BitConverter]::ToUInt32($bytes, 0x1E9D)
$oldSz = [BitConverter]::ToUInt32($bytes, 0x1EA4)
Write-Host ("Old TimeDateStamp: 0x{0:X8}, Old SizeOfImage: 0x{1:X8}" -f $oldTs, $oldSz)

if ($oldTs -ne 0x6AC397B7 -or $oldSz -ne 0x06726000) {
    throw "Unexpected original immediates at 0x1E9D / 0x1EA4!"
}

$newTsBytes = [BitConverter]::GetBytes([uint32]0x6ACFE9AB)
$newSzBytes = [BitConverter]::GetBytes([uint32]0x0796C000)
[Array]::Copy($newTsBytes, 0, $bytes, 0x1E9D, 4)
[Array]::Copy($newSzBytes, 0, $bytes, 0x1EA4, 4)

$newSlice = ($bytes[0x1E9A..0x1EA7] | ForEach-Object { $_.ToString("X2") }) -join " "
Write-Host "Patched bytes at 0x1E9A..0x1EA7:  $newSlice"

[System.IO.File]::WriteAllBytes($versionDllPath, $bytes)
Write-Host "Saved patched version.dll for 48146 to $versionDllPath"
