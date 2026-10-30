# Local BE tools

These PowerShell 7 scripts belong to SPT-BE because they operate on an installed game, rather than implement a mod. Pass the target installation explicitly. Never use a previous installation as a scratch directory.

## Controls

`Import-LiveControls.ps1 -GamePath <game> [-LiveControls <file>] [-WhatIf]` imports Control.ini, validates its schema, backs up the destination, and verifies the copy. The default source is the live game's AppData settings. Close the client first. See the root README for the recorded import and backup location.

## Server and client smoke checks

1. Build production and test projects using the mod's test README. Back up profiles while the server is stopped. Use a disposable account for tests that modify state: an account name starting with LocalBuildTest does **not** prove it is disposable. James also plays one such account.
2. Copy only that mod's temporary test DLL to its installed plugin/mod directory. Never copy game reference assemblies from build outputs. Close the normal game/server first; the start helper refuses to replace an existing process.
3. Start the server, retaining the returned process record:

```powershell
$game = 'C:\sptarkov\SPTarkov 5.0.0-BE-1.3.0.0.48484'
$server = ./scripts/Start-BESmokeProcess.ps1 -Kind Server -GamePath $game -OutputDirectory .local-build-attempt/smoke
Get-Content "$($server.LogPrefix).log" -Tail 30
# Wait for the server's ready message, then use the chosen LocalBuildTest account ID.
$client = ./scripts/Start-BESmokeProcess.ps1 -Kind Client -GamePath $game -OutputDirectory .local-build-attempt/smoke -ProfileId '<24-hex-test-account-id>'
Get-Content "$game/BepInEx/LogOutput.log" -Tail 60
```

4. Read the mod-specific PASS/FAIL results and errors. A successful build or process start alone does not prove a test passed. Save BepInEx/LogOutput.log before launching again, as it is overwritten. Client Unity logs and server output use timestamped files in OutputDirectory.
5. Close the recorded client, remove the exact temporary test DLL, and stop the recorded server:

```powershell
./scripts/Stop-BESmokeProcess.ps1 -StateFile $client.StateFile -Force
# Remove only the temporary harness DLL named in that mod's test README.
./scripts/Stop-BESmokeProcess.ps1 -StateFile $server.StateFile -Force
```

The stop helper checks PID, executable path and process start time before stopping anything. It first attempts a graceful window close; `-Force` permits termination of that verified process. Both helpers support `-WhatIf`. If the shell session is lost, supply the saved `*-process.json` file directly. These files are local records, not portable configuration.

The client helper uses the current local HTTPS backend on port 6969 and launch arguments matching this BE installation. It checks account naming and that the matching server process exists; it does not select a character, enter a raid, drive UI, or verify server readiness. Normal startup can write profile timestamps. Never restore a profile while its server is running.

## Where tests live

| Owner | Repeatable checks |
| --- | --- |
| WebOverlay fork | `tests/RuntimeChecks.csproj`, `tools/Probe` and `tests/README.md` |
| QuestMarkers fork | `tests/RuntimeChecks.csproj` and `tests/README.md` |
| AllQuestsCheckmarks fork | `tests/RuntimeChecks.csproj`, `tests/server_probe.py` and `tests/README.md` |
| AnyPlaceAnyTime repo (formerly AlwaysSpecial) | `tests/PolicyTests.csproj`, `tests/RuntimeChecks.csproj`, `tools/generate_catalog.py`, `tools/Inspect` and `tests/README.md` |
| Ref Friendly Quests fork | `tests/RuntimeChecks.csproj`, `tests/verify_runtime.py`; instructions in mod README |
| FreeTarcoins fork | `Tests/Tests.csproj`, `Tests/integration.py`; instructions in mod README |
| Server fork | Shop unit tests and `Testing/LocalIntegration/stash_cap.py` |

Reusable source and instructions are committed in the owning repo. Installed DLLs, captured HTML, profiles/backups, process records and logs stay in ignored local directories. Old one-off repair scripts are historical scratch artifacts, not supported migration tools. Do not rerun them against current saves.

## SVM local BE build and startup checks

SVM's personal-use license prohibits sharing modified versions. The public fork/submodule therefore pins upstream `10957bc849dc6be7b4a3de60f63331e954401fbf`; local compatibility commit `e8e198844fbfdaa6c54e40c5554e2fe7d00465b2` is deliberately not pushed. Do not blindly push that branch or reset the local checkout to its public pin. The parent README describes the two personal-use edits. These parent tools belong here because they adapt the build to this local BE installation, generate its installation preset, and manage its GUI process; they do not distribute upstream source.

From the parent repository, with .NET 10 SDK and Windows Desktop runtime installed:

```powershell
$game = 'C:/sptarkov/SPTarkov 5.0.0-BE-1.3.0.0.48484'
$adapter = (Resolve-Path scripts/Svm.LocalReferences.targets).Path
dotnet build mods/svm-csharp/ServerValueModifier -c Release "-p:CustomAfterMicrosoftCommonTargets=$adapter" "-p:SPTPath=$game"
# Upstream Greed requires its embedded optional resource, absent from the checkout:
Invoke-WebRequest 'https://github.com/GhostFenixx/HideSpecialIcon/releases/download/4.0.13/HideSpecialIconGrids.dll' -OutFile mods/svm-csharp/Greed/Resources/HideSpecialIconGrids.dll
dotnet publish mods/svm-csharp/Greed -c Release -r win-x64 --self-contained false -p:PublishSingleFile=true -o .local-build-attempt/svm/Greed
# Output must be NEW; never overwrite an edited installed preset:
dotnet run --project scripts/SvmPreset -c Release -- .local-build-attempt/svm/New-Defaults.json
./scripts/Test-SvmGreed.ps1 -GamePath $game -OutputDirectory .local-build-attempt/svm
```

The reference adapter removes old SPT NuGet references and uses the installed runtime; it does not edit upstream project files. SvmPreset checks all 15 section gates are false and verifies typed JSON roundtrip before writing a new file. Test-SvmGreed checks the main window responds, captures evidence and closes only its own process; it does not operate settings or validate rendered controls. For server testing use the owned Start/Stop-BESmokeProcess helpers above, and require both SVM initialization/preset success and normal server readiness. Keep backups/logs local. The optional embedded Mono plugin is **not installed**; its Greed install button is disabled by the personal compatibility change.
