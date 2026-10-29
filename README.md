# SPT-BE workspace

Parent repository: [jpeckham/SPT-BE](https://github.com/jpeckham/SPT-BE). Child projects are pinned submodules of James's forks. See [source-control workflow](docs/SOURCE-CONTROL.md) for cloning, committing child changes, and updating the parent pins. Build histories below remain the record of how this local installation was produced.

> **48146 baseline locked on 2026-10-29:** the installation is now `C:\sptarkov\SPTarkov 5.0.0-BE-1.2.5.0.48146`. Historical commands below retain the original `SPTarkov 5.0.0-local` path; use the renamed path for current builds. The five mod forks now use `spt-5.0-eft-1.2.5.0.48146`, with published baseline tags. See [the baseline record](docs/BASELINE-EFT-1.2.5.0.48146.md) for commits, backups, verification and unresolved issues. New EFT work must use a separate installation and branch.

# How this local SPT 5.0 / EFT 48146 build was made

This is the step-by-step history of **your build**, assembled on October 25, 2026 and installed at `C:\SPT-5.0.0`. It explains what Antigravity actually did, which files it used, and which preparation steps it devised. The later audio-crash patch is separate, at the end.

This is not the SPT team's official build guide. It was reconstructed from the original Antigravity tool calls and outputs, not just the AI's completion summaries. The commands are presented for understanding and reconstruction; none of these build/install commands were run while writing this guide.

The independent October 28–29 Codex attempt is documented separately in [Codex independent attempt](#codex-independent-attempt--october-2829-2026) below. It targets `C:\sptarkov\SPTarkov 5.0.0-local` and does not replace this historical account.

## Read this first

- **Historical input:** "latest Tarkov" meant **1.2.5.0.48146 at the time**. A newer live installation is not an interchangeable input.
- **Working directory:** commands below start from `C:\Users\james\source\repos\SP-Tushonka`, unless explicitly using `Push-Location`.
- **Paths:** the recovered scripts contain James's absolute paths. They are preserved as historical source, not rewritten into portable tooling.
- **Existing installation:** the copy/extract commands describe the original installation. Running them again over the current installation would overwrite files, including potentially the later audio fix. Use a separate destination for a reconstruction.
- **Labels:** “repository tooling” means the operation exists in the project's tooling/docs; “local adaptation” means Antigravity supplied an implementation or selected inputs without an established team recipe.

The sequence was:

```text
Live EFT 48146 + development repositories
  -> build launcher/server and updated interop/runtime dependencies
  -> patch an older loader's client checks
  -> patch a COPY of EFT metadata
  -> generate interop references with a custom helper
  -> compile modules against those references
  -> package everything with Bento
  -> copy EFT and overlay the archive into C:\SPT-5.0.0
  -> launch and test
  -> later: investigate crash, patch modules, replace SinglePlayer DLL
```

## Build identity and inputs

Workspace: `C:\Users\james\source\repos\SP-Tushonka` (separate Git repositories beneath this directory).

| Component | Recorded input |
| --- | --- |
| EFT | `1.2.5.0.48146`; executable product version `1.2.5.0-48146-d8a79361` |
| Live game source | `C:\Battlestate Games\Escape from Tarkov` |
| Unity | `2022.3.43f2` |
| .NET SDK | `10.0.302`, recorded in the handoff |
| server-csharp | `5.0x-dev`, `c775c3bbe` |
| launcher | `5.0.x-dev`, `189774f` |
| modules, original archive | `5.0x-dev`, `bb20512` |
| Il2CppInterop | `6a04b2c`, version `1.6.8` |
| BepInXDX | `08c2ac0` |
| Bento | checkout at `dfb7d59`; manifest reports version `0.2.5`; static assets modified locally |
| Loader donor | Bento Git blob `53a48e6:assets/il2cpp/version.dll` |
| modules, later installed fix | `9a5e4da`, `Fix local raid startup crash in AudioUtils.ResetAudioBuffer` |

The original manifest records clean server/modules trees and a dirty launcher tree. The continuation transcript later identifies launcher changes as build-generated and restores them. It also restores the temporary BepInXDX project edits after the binaries were built. A clean working tree today does not describe the inputs at build time.


## Why Antigravity took each step

The distinctions below matter: a command failing in our environment is not proof that it fails in the team's environment. Likewise, a preparation recipe not found in the public repositories is not proof that the team has no internal recipe. “Missing documentation” here means we did not locate a public procedure sufficient to reproduce that input.

| Step | Why it was needed | What prompted Antigravity's action | Classification |
| --- | --- | --- | --- |
| 1. Select development sources | Find the code targeting EFT 48146 rather than build an older release. | The investigation found relevant updates on the 5.0 development branches. Antigravity selected their current commits; it did not have a coordinated team release tag for this build. | Local source selection; not a failed team command. |
| 2. Build launcher/test server | Check that the selected projects build and obtain the launcher dependencies used later. | Ordinary build preparation. The first server command named a nonexistent solution; Antigravity corrected it to `server-csharp.slnx`. | Routine build work; the wrong solution name was Antigravity's own error. |
| 3. Build Il2CppInterop | Obtain newer interop code containing fixes identified in the investigation. | Antigravity judged Bento's bundled dependencies to be behind the source revisions it wanted to use. | Local dependency-update decision; not evidence that rebuilding was required to fix a reproduced failure. |
| 4. Substitute Cpp2IL references | Make the BepInXDX IL2CPP project build with the available dependencies. | Restore actually failed with `NU1102` for `Samboy063.Cpp2IL.Core` version `2022.1.0-xdx.*` on the configured sources. Antigravity used the existing Bento DLLs instead. | Observed local dependency failure followed by an AI-devised workaround. The team's access to other feeds/artifacts is unknown. |
| 5. Overlay Bento runtime assets | Ensure the archive ships the runtime files just built. | Bento packages its asset directory; it does not automatically consume the sibling BepInXDX build output. | Consequence of the local dependency-update decision; an explicit manual integration step. |
| 6. Patch the older loader | Supply a loader that accepts the target client's PE identity. | The public release workflow builds a version-matched loader from a private repository. Our sessions did not build that source or obtain the corresponding team-produced loader. Antigravity examined an older binary and changed its client checks. | Missing accessible build input, followed by an AI-devised binary port. Not a failed execution of the team's loader build. |
| 7. Write InteropGenRunner | Produce the assembly references needed to compile modules for 48146. | Bento expects an already-prepared reference package. We did not obtain the team's matching package or locate its exact public production recipe. Antigravity adapted the generation API sequence visible in BepInXDX into a standalone program. | Gap in publicly reproducible input preparation, filled by custom helper code. The generator APIs themselves are existing project machinery. |
| 8. Generate references | Turn the native game and patched metadata into the .NET reference assemblies consumed by modules. | Execution of the helper created in Step 7. Applying the metadata delta and supplying Unity libraries were explicit operations in that helper. | Custom preparation path; successful generation does not establish equivalence to the team's package. |
| 9. Build modules | Compile the client patches against the generated references. | The modules README documents referencing `BepInEx/core` and `BepInEx/interop` through `GameDir`. | Documented build pattern using locally prepared inputs. |
| 10. Run Bento | Build and combine the server, launcher, modules, runtime assets, and loader into an archive. | Bento documents development builds from local working copies and accepts a local reference-package directory. | Supported tooling path; the inputs and chosen version label remain our responsibility. |
| 11. Install the archive | Create a separate EFT copy with the generated SPT files overlaid. | The archive needed a game installation to run against. Antigravity supplied copy/extraction instructions, which the user reported following manually. | Normal installation pattern applied to our custom archive; not evidence of a team-distributed build. |
| 12. Launch and test | Find out whether the assembled build runs and behaves correctly. | The user started the server and client, then tested gameplay. | Runtime validation after packaging; this is when the Factory crash was reported. |
| Later audio patch | Avoid the observed Factory startup crash. | After investigating the native audio-reset path, Antigravity chose to skip `AudioUtils.ResetAudioBuffer` in modules. | Local workaround for an observed crash; attribution to a game defect versus a custom-build problem remains unresolved. |

### What the evidence establishes

The clearly recovered dependency failure was the unavailable Cpp2IL package version in Step 4. The larger obstacles were obtaining the version-matched loader and reference-package inputs. Antigravity supplied its own preparation for those inputs rather than reproducing a complete, publicly documented team recipe.

Two distinctions prevent overstating that conclusion:

- **Il2CppInterop `1.6.7` resolving to `1.6.8` was a NuGet warning**, not the error that stopped the BepInXDX build. The missing Cpp2IL package caused that failure.
- **Antigravity's first project-file edit failed because its replacement text did not match.** That was an agent editing failure, not a defect in the team's build process. The subsequent narrower edit succeeded.

The source updates, static checks, and eventual successful gameplay explain why Antigravity continued. They do not demonstrate that its chosen dependency combination, loader port, or reference package matched the team's development baseline. The later audio patch therefore cannot, by itself, establish which component originally caused the crash.

## Step 1 — Obtain the source checkouts and select the development branches

**What happened:** the first session cloned the SP-Tushonka repositories into this workspace, selected the 5.0 development branches, and obtained Git LFS assets. The build-relevant repositories are listed in the table above; cloning all organization repositories is not itself required for packaging.

These were the branch selections:

```powershell
Set-Location C:\Users\james\source\repos\SP-Tushonka

git -C server-csharp checkout 5.0x-dev
git -C modules checkout 5.0x-dev
git -C launcher checkout 5.0.x-dev
dotnet --list-sdks
```

**Result:** the three main projects were at `c775c3bbe`, `bb20512`, and `189774f`. The SDK was recorded as `10.0.302`.

**For reconstruction:** branch names move. Use the exact revisions in the input table in separate checkouts, rather than assuming today's branch heads contain the same code. Have Git LFS, .NET 10 SDK, and 7-Zip installed. Keep the original 48146 game files available.

**Origin:** repository tooling, with development revisions selected locally rather than a coordinated release tag.

## Step 2 — Build the launcher and test the server

```powershell
Push-Location ./launcher
dotnet build SPTushonka.Launcher.slnx -c Release
Pop-Location

Push-Location ./server-csharp
dotnet test server-csharp.slnx -c Release
Pop-Location
```

**Why:** this checked that the main projects built and supplied the `SharpHDiffPatch.Core.dll` later used to patch the metadata copy.

**Result:** launcher built; the server Release test output records **466 passed, 0 failed**. An initial command used the wrong server solution name; the successful command above uses `server-csharp.slnx`.

A separate Debug investigation temporarily enabled strict JSON unmapped-member handling, then restored the original setting. That diagnostic edit was not retained as part of the intended build.

**Origin:** repository tooling.

## Step 3 — Build Il2CppInterop 1.6.8

```powershell
Push-Location ./Il2CppInterop
dotnet build Il2CppInterop.sln -c Release
Pop-Location
```

**Input:** Il2CppInterop `6a04b2c`.

**Result:** compiled assemblies and `1.6.8` NuGet packages, including packages under `Il2CppInterop/bin/NuGet`.

**Origin:** repository tooling. Choosing to replace Bento's bundled runtime with this newer local build was a local preparation decision.

## Step 4 — Work around the missing Cpp2IL package and build BepInXDX

This is a material local adaptation, not a routine successful build of an unchanged checkout.

**What failed:** BepInXDX's IL2CPP project referenced:

```xml
<PackageReference Include="Samboy063.Cpp2IL.Core" Version="2022.1.0-xdx.*" />
```

Restore could not find that version (`NU1102`). Antigravity replaced that one package reference in:

```text
BepInXDX/Runtimes/Unity/BepInEx.Unity.IL2CPP/BepInEx.Unity.IL2CPP.csproj
```

with eight direct assembly references into Bento's existing `assets/il2cpp/BepInEx/core` folder. The exact successful replacement is saved in [BepInXDX-reference-replacement.xml](docs/build-48146/BepInXDX-reference-replacement.xml):

```xml
        <Reference Include="Cpp2IL.Core">
            <HintPath>..\..\..\..\bento\assets\il2cpp\BepInEx\core\Cpp2IL.Core.dll</HintPath>
        </Reference>
        <Reference Include="LibCpp2IL">
            <HintPath>..\..\..\..\bento\assets\il2cpp\BepInEx\core\LibCpp2IL.dll</HintPath>
        </Reference>
        <Reference Include="Disarm">
            <HintPath>..\..\..\..\bento\assets\il2cpp\BepInEx\core\Disarm.dll</HintPath>
        </Reference>
        <Reference Include="WasmDisassembler">
            <HintPath>..\..\..\..\bento\assets\il2cpp\BepInEx\core\WasmDisassembler.dll</HintPath>
        </Reference>
        <Reference Include="StableNameDotNet">
            <HintPath>..\..\..\..\bento\assets\il2cpp\BepInEx\core\StableNameDotNet.dll</HintPath>
        </Reference>
        <Reference Include="AssetRipper.CIL">
            <HintPath>..\..\..\..\bento\assets\il2cpp\BepInEx\core\AssetRipper.CIL.dll</HintPath>
        </Reference>
        <Reference Include="AssetRipper.Primitives">
            <HintPath>..\..\..\..\bento\assets\il2cpp\BepInEx\core\AssetRipper.Primitives.dll</HintPath>
        </Reference>
        <Reference Include="Gee.External.Capstone">
            <HintPath>..\..\..\..\bento\assets\il2cpp\BepInEx\core\Gee.External.Capstone.dll</HintPath>
        </Reference>
```

**Important historical detail:** Antigravity first attempted a larger edit that also changed Il2CppInterop package versions from `1.6.7` to `1.6.8`. That edit **failed** because its target text did not match. The later successful edit only replaced the Cpp2IL package reference. NuGet resolved the still-requested Il2CppInterop `1.6.7` packages to `1.6.8`, with `NU1603` warnings. Do not mistake the attempted edit for an applied change.

After the successful reference substitution:

```powershell
Push-Location ./BepInXDX
dotnet build Runtimes/Unity/BepInEx.Unity.IL2CPP/BepInEx.Unity.IL2CPP.csproj `
  -c Release `
  -p:SolutionDir=C:\Users\james\source\repos\SP-Tushonka\BepInXDX\ `
  -p:GeneratePackageOnBuild=false
Pop-Location
```

**Result:** successful build, with runtime files in `BepInXDX/bin/Unity.IL2CPP`.

The restore diagnostics include the local `Il2CppInterop/bin/NuGet` source. The recovered sequence does not establish a standalone command that initially configured that source, and package-cache/source state is a reconstruction dependency. For a new environment, explicitly establish the required package sources/versions instead of relying on the historical fallback.

**Origin:** repository build command, with AI-devised dependency substitution. The temporary project edit was reverted later, after the binaries were produced.

## Step 5 — Replace Bento's runtime assets with the newly built files

```powershell
Copy-Item ./BepInXDX/bin/Unity.IL2CPP/* `
  ./bento/assets/il2cpp/BepInEx/core/ -Force
```

**Why:** Bento packages its static assets. Building BepInXDX elsewhere does not automatically update what Bento ships.

**Result:** Bento's `core` directory contained the new build outputs plus existing files not overwritten, including `dobby.dll`. This was an overlay, not a clean regeneration of every dependency in that folder.

**Origin:** local adaptation. The exact original combined command for Steps 5–6 is preserved in [SyncRuntimeAndPatchLoader.ps1](docs/build-48146/SyncRuntimeAndPatchLoader.ps1). It contains absolute paths and overwrites these outputs.

## Step 6 — Adapt the older version.dll to accept the 48146 client

**Input:** 191,488-byte `version.dll` extracted from Bento's Git blob:

```text
53a48e6:assets/il2cpp/version.dll
```

Antigravity did not compile the private loader source. It used `git cat-file blob` through a process's binary output stream, then modified two four-byte little-endian comparison operands:

| File offset of operand | Check | Required original value | Written value |
| --- | --- | --- | --- |
| `0x1E9D` | GameAssembly PE timestamp | `0x6AC397B7` | `0x6ACFE9AB` |
| `0x1EA4` | GameAssembly PE image size | `0x06726000` | `0x0796C000` |

The script checked the original values before writing the new ones. The result was saved as:

```text
bento/assets/il2cpp/version.dll
```

`0x1E9A` is the first comparison instruction's starting offset, not the operand offset. The preserved script contains the actual binary extraction and write operations; it avoids the ambiguity of copying binary data through text output.

Before doing this, the first session disassembled the donor and checked four loader signature patterns against the 48146 `GameAssembly.dll`, finding one match each. [HANDOFF_CONTEXT.md](HANDOFF_CONTEXT.md) records the signatures and matching RVAs.

**Origin:** AI-devised binary port. These checks justified an experiment; they did not prove equivalence to the team's loader for this client. The offsets are valid only for the stated donor.

## Step 7 — Create the custom reference-generation helper

Antigravity wrote a separate .NET 10 console project called `InteropGenRunner` in its session scratch directory. The exact retained source and project have now been copied into this workspace:

- [Program.cs](docs/build-48146/InteropGenRunner/Program.cs)
- [InteropGenRunner.csproj](docs/build-48146/InteropGenRunner/InteropGenRunner.csproj)

These are unmodified copies of the retained helper, including its absolute paths and direct DLL references. They are historical artifacts, not a newly designed build tool.

**Inputs used by that helper:**

| Input | Location |
| --- | --- |
| Native game code | `C:\Battlestate Games\Escape from Tarkov\GameAssembly.dll` |
| Original metadata | Live game's `EscapeFromTarkov_Data/il2cpp_data/Metadata/global-metadata.dat` |
| Metadata delta | `launcher/SPTushonka.Core/SPT_Data/Launcher/Patches/SPT-core/EscapeFromTarkov_Data/il2cpp_data/Metadata/global-metadata.dat.delta` |
| Delta library | `launcher/SPTushonka.Launcher/bin/Release/net10.0/SharpHDiffPatch.Core.dll` |
| Core tool/runtime DLLs | `bento/assets/il2cpp/BepInEx/core` |
| Unity reference libraries | `bento/assets/il2cpp/BepInEx/unity-libs/2022.3.43.zip` |

**Origin:** AI-written runner invoking the same Cpp2IL and Il2CppInterop generator APIs used by BepInXDX. It was not a retrieved team reference-package production script.

## Step 8 — Run the helper to make .gamedir-48146

Original invocation:

```powershell
dotnet run --project "C:\Users\james\.gemini\antigravity\brain\3d218256-cfe7-42e1-99ec-4f7e64bdaa00\scratch\InteropGenRunner\InteropGenRunner.csproj" -c Release
```

With the preserved copy, the equivalent project invocation is:

```powershell
dotnet run --project ./docs/build-48146/InteropGenRunner/InteropGenRunner.csproj -c Release
```

The helper still reads and writes the original absolute paths. Review them before running it. Its operations, in order, are:

1. Create `.gamedir-48146/BepInEx/core`, `unity-libs`, and `interop`.
2. Copy the updated Bento core DLLs into `.gamedir-48146/BepInEx/core`.
3. Apply the metadata delta to the live metadata **as an input**, writing a patched copy to `.gamedir-48146/global-metadata.dat`.
4. Extract the Unity base library ZIP into `.gamedir-48146/BepInEx/unity-libs`.
5. Initialize Cpp2IL with the live `GameAssembly.dll`, that patched metadata copy, and Unity `2022.3.43f2`.
6. Run `AttributeInjectorProcessingLayer`, then `AsmResolverDllOutputFormatDefault` to obtain assembly definitions.
7. Run `Il2CppInteropGenerator` with those definitions, the game assembly, the Unity libraries, and `.gamedir-48146/BepInEx/interop` as output. No rename map or obfuscation regex is supplied by this helper.
8. Write `assembly-hash.txt` for the generated interop cache.

**Recorded output:** 169 interop DLLs in about 59 seconds; patched metadata size 32,118,848 bytes; cache marker `e42ef62565a186591861a5a231b6e788`.

```text
.gamedir-48146/
  global-metadata.dat
  BepInEx/
    core/
    unity-libs/
    interop/
      Assembly-CSharp.dll
      ...other generated DLLs...
      MethodAddressToToken.db
      MethodXrefScanCache.db
      assembly-hash.txt
```

**This directory was our reference package.** Bento accepts a directory, so Antigravity did not need to produce or download a separate `48146.7z` reference archive. The cache marker is not a complete hash inventory of all inputs.

## Step 9 — Compile modules using those references

```powershell
dotnet build ./modules/SPTushonka.Build/SPTushonka.Build.csproj `
  -c Release `
  -p:SPTushonkaVersion=5.0.0 `
  -p:GameDir=C:\Users\james\source\repos\SP-Tushonka\.gamedir-48146
```

**Why:** `GameDir` tells the modules projects where to find the `BepInEx/core` and `BepInEx/interop` assembly references created above.

**Result:** the prepatch DLL under `modules/Build/BepInEx/patchers` and plugin DLLs under `modules/Build/BepInEx/plugins/sptushonka`.

Antigravity also used a scratch verifier. Its retained output reports 38 gated exports decoded, 203 ungated exports, and 49/49 patch targets resolved, including two marked `InlinedInto`. These were static checks, not gameplay validation.

**Origin:** documented modules build pattern, supplied with our locally generated reference directory.

## Step 10 — Let Bento build, assemble, and archive the distribution

From the workspace root, this is the actual command with paths shortened to relative equivalents:

```powershell
dotnet run --project ./bento/Bento.csproj -c Release -- `
  --no-config `
  --version 5.0.0 `
  --build-type BLEEDINGEDGEMODS `
  --server ./server-csharp `
  --modules ./modules `
  --launcher ./launcher `
  --module-package ./.gamedir-48146 `
  --version-dll ./bento/assets/il2cpp/version.dll `
  --output ./dist
```

**What each important option supplied:**

- `--server`, `--modules`, `--launcher`: the local working trees.
- `--module-package`: our generated compilation references.
- `--version-dll`: our patched loader.
- `--version` and `--build-type`: output version/channel labels, not certification by the team.
- `--no-config`: explicit arguments rather than a saved Bento configuration.

Bento rebuilt the main components, merged their outputs, overlaid static runtime assets, and made the archive. It ran in **dev mode**, not `--fresh --tag`.

**Outputs:**

| Artifact | Recorded result |
| --- | --- |
| Archive | `dist/SPT-BLEEDINGEDGEMODS-5.0.0-48146-c775c3bbe-20261025.7z` |
| Size | 677,547,373 bytes; 2,786 files |
| Manifest | [dist/manifest.json](dist/manifest.json) |
| Manifest timestamp | `2026-10-25T23:03:14Z` |
| Archive MD5, Base64 | `UZLR+GiqHFAKXacPotsxKQ==` |
| NuGet packages | `dist/packages`, version `5.0.0-pre.202610252303` |
| Build logs | `dist/logs/{server,launcher,modules,assemble,nuget,package}.log` |

Archive SHA-256 measured October 28:

```text
32199A6B7A073211F17249933F47BA391F558810750C06A91CD7BF275CD6BFB4
```

**Origin:** Bento's supported local-development packaging path. The prepared loader and reference/runtime inputs were our own.

**At this point the original “SPT build” was finished. No audio patch had been added.**

## Step 11 — Install the archive over a copy of EFT

Antigravity supplied these instructions. The user then said they performed the setup manually; the transcript does not contain a tool-executed copy/extraction log.

The original commands were:

```powershell
$TargetDir = "C:\SPT-5.0.0"

# Copy the live 48146 installation into a separate directory.
robocopy "C:\Battlestate Games\Escape from Tarkov" $TargetDir /E /MT:16 /XD "Logs" "cache"

# Overlay the archive built in Step 10.
& "C:\Program Files\7-Zip\7z.exe" x `
  "C:\Users\james\source\repos\SP-Tushonka\dist\SPT-BLEEDINGEDGEMODS-5.0.0-48146-c775c3bbe-20261025.7z" `
  "-o$TargetDir" -y

# Optional: reuse the interop files instead of generating them on first launch.
robocopy "C:\Users\james\source\repos\SP-Tushonka\.gamedir-48146\BepInEx\interop" `
  "$TargetDir\BepInEx\interop" /E /MT:16
```

For interpreting a reconstruction run: Robocopy exit codes below 8 are not necessarily failures; 8 or greater indicates a copy failure. Do not proceed with a failed/incomplete game copy.

**Result:** a separate game installation at `C:\SPT-5.0.0` with `BepInEx`, the loader/runtime files, and `SPT_Runtime` containing the server and launcher.

## Step 12 — Start the server and game, then test

1. Run `C:\SPT-5.0.0\SPT_Runtime\SPT.Server.exe` and wait for startup to complete.
2. Run `C:\SPT-5.0.0\SPT_Runtime\SPT.Launcher.exe`.
3. Set the launcher's game path to `C:\SPT-5.0.0`.
4. Create/select a profile and start the game through the launcher.
5. The launcher applies its metadata patch to the **copied game installation**. The earlier helper patched a separate metadata copy for generating references; those are different destinations.
6. Inspect `BepInEx/LogOutput.log`, the game's Unity log, and `SPT_Runtime/user/logs` while testing.

The user reported running the installation and subsequently reported a crash while loading Factory. The original build succeeded far enough to launch and test; this does not establish complete client compatibility.

## Later, separate work — Fix the observed audio crash locally

After the original build and testing, Antigravity investigated the Factory crash and added [ResetAudioBufferPatch.cs](modules/SPTushonka.SinglePlayer/Patches/RaidFix/ResetAudioBufferPatch.cs). That prefix skips EFT's `AudioUtils.ResetAudioBuffer` entirely.

It rebuilt modules with the Step 9 command and copied this one DLL:

```powershell
Copy-Item ./modules/Build/BepInEx/plugins/sptushonka/SPTushonka.SinglePlayer.dll `
  C:/SPT-5.0.0/BepInEx/plugins/sptushonka/SPTushonka.SinglePlayer.dll -Force
```

The change became commit `9a5e4da` and [modules PR #6](https://github.com/SP-Tushonka/modules/pull/6), closed without merge. The PR reports successful Factory gameplay and extraction afterward. The patch avoids a crash trigger; it does not prove the cause of the underlying memory fault.

The original archive's manifest records modules `bb20512`. It therefore describes the original build, while the installation later received the audio fix.

On October 28 the installed SinglePlayer DLL matched the workspace build output, SHA-256:

```text
A80FE8057D5C1278B88BC9DBA9041E99C75EE5A6BF75F724330E02F47183C3C0
```

The installed loader matched `bento/assets/il2cpp/version.dll`, SHA-256:

```text
D2C7912DDE4133946057653C7039F7FB9FB46A1F66771772417820CE788C6A8A
```

Later cleanup restored the launcher build-generated changes and temporary BepInXDX project modification. It did not undo the already-built/deployed binaries.

## Validation and reproducibility limits

- The original server Release test log records **466 passed, 0 failed**.
- The generator log records **169 interop DLLs generated**.
- The static patch verification output records **49/49 targets resolved, 0 failed, 2 with `InlinedInto`**. Resolution is not proof that all patches execute correctly.
- Packaging completed successfully. The PR records a successful Factory raid, bot engagement, extraction, and menu return after the workaround. That is reported gameplay validation, not a fresh test performed for this README.
- The loader port, runtime-asset overlay, temporary project edits, and locally generated references are material differences from simply checking out a release tag.
- There is no complete immutable inventory of the original game files, dependency binaries, transient project changes, or all installed files. This is a recovered build history with useful reconstruction commands, not a guarantee of a byte-identical rebuild.
- Running the command against today's branch heads will not reproduce the original archive. Use the recorded revisions and preserve the original artifacts and helper source.

## Original session evidence

Both chats are available locally as readable JSONL transcripts under Antigravity's `brain` directory; accessing them did not require decoding the conversation databases or an IDE export.

| Session | ID | Contents |
| --- | --- | --- |
| Initial investigation/handoff | `dc88508f-7bdd-437b-a60e-fd1ccb90ff14` | Upgrade plan, dependency builds, loader analysis, handoff |
| Continuation | `3d218256-cfe7-42e1-99ec-4f7e64bdaa00` | Reference generation, packaging, installation follow-up, crash investigation and patch |

Local source links (specific to this machine):

- [First chat transcript](C:/Users/james/.gemini/antigravity/brain/dc88508f-7bdd-437b-a60e-fd1ccb90ff14/.system_generated/logs/transcript.jsonl)
- [Second chat transcript](C:/Users/james/.gemini/antigravity/brain/3d218256-cfe7-42e1-99ec-4f7e64bdaa00/.system_generated/logs/transcript.jsonl)
- [Original upgrade plan](C:/Users/james/.gemini/antigravity/brain/dc88508f-7bdd-437b-a60e-fd1ccb90ff14/spt_50_upgrade_plan.md)
- [Interop generator source](C:/Users/james/.gemini/antigravity/brain/3d218256-cfe7-42e1-99ec-4f7e64bdaa00/scratch/InteropGenRunner/Program.cs)
- [Interop generator project and dependency paths](C:/Users/james/.gemini/antigravity/brain/3d218256-cfe7-42e1-99ec-4f7e64bdaa00/scratch/InteropGenRunner/InteropGenRunner.csproj)
- [Successful generation log](C:/Users/james/.gemini/antigravity/brain/3d218256-cfe7-42e1-99ec-4f7e64bdaa00/.system_generated/tasks/task-45.log)
- [Static patch verification output](C:/Users/james/.gemini/antigravity/brain/3d218256-cfe7-42e1-99ec-4f7e64bdaa00/.system_generated/steps/68/output.txt)
- [Server Release test output](C:/Users/james/.gemini/antigravity/brain/dc88508f-7bdd-437b-a60e-fd1ccb90ff14/.system_generated/tasks/task-81.log)

Each session's logs directory also contains `transcript_full.jsonl`; some compact transcript entries truncate long tool arguments. Step output files and task logs provide supporting evidence. Scratch helpers may have been modified later in the same session: in particular, `VerifyPatches48146` was subsequently reused for other investigations, so its current source is not necessarily the original verifier.

Raw transcripts have not been copied into this workspace or published. They include unrelated follow-up discussion and operational details; this README extracts the relevant build history.

---

## Codex independent attempt — October 28–29, 2026

**This section records a different build, executed by Codex.** The destination is `C:\sptarkov\SPTarkov 5.0.0-local`. `C:\SPT-5.0.0` was not modified. Dates cross midnight UTC; local date was October 28 (America/Chicago).

This is an **experimental local port**, not a matching official release. The documented official installation path requires a matching game/archive pair; the available October 10 archive targets 47965 while the installed game is 48146. The user explicitly authorized attempting to bridge that gap.

### C1. Establish an isolated workspace and copy the game

All commands below start at `C:\Users\james\source\repos\SP-Tushonka`. Experiment files, checkouts, scripts, and logs live under `.local-build-attempt/2026-10-28`.

```powershell
robocopy 'C:\Battlestate Games\Escape from Tarkov' `
  'C:\sptarkov\SPTarkov 5.0.0-local' /E /COPY:DAT /DCOPY:DAT /MT:8 /R:1 /W:1
```

**Why/origin:** follows the team's full-copy installation approach, with a separate destination as requested. No exclusions or mirror deletion. Result: 11,787 files, 86,213,304,511 bytes; robocopy exit 1 (successful copy). A dry-run comparison found no pending copies, mismatches, failures, or extras. GameAssembly and metadata SHA-256 matched the live source. Exact hashes and original preflight results are in [attempt.json](.local-build-attempt/2026-10-28/attempt.json).

### C2. Pin the public tooling and source inputs

| Component | Input |
| --- | --- |
| Installed game | `1.2.5.0-48146-d8a79361` |
| Bento | tag `v0.2.6`, commit `6fca3ff9ae340236b609abc1cafe6f927d0f26b4` |
| Server | `bd58e5ec4d1a665c69bf12762be5017f7fbb6983` |
| Launcher | `189774f4374dc3676291a36a5eb188a94877099b` |
| Modules | `bb205121fa55c6e0bfcb6b0d2f5d32fa2e99a096`, **without ResetAudioBufferPatch** |
| Il2CppInterop, added after first build failure | `6a04b2c6299ac2aee658f3ffb18aab0a638cd6cc` |
| Initial BepInXDX/runtime assets | exact files from the official October 10 archive; BepInXDX reports commit `d08d3289115740d15a0f618cf0331030bf88e3d5` |

Bento was cloned at its tag and built with `dotnet build Bento.csproj -c Release`. The other repositories were cloned separately with `git clone --no-hardlinks` from the existing local repositories, then checked out at the commits above. The server was additionally fetched from the public `5.0x-dev` branch before pinning. This preserves existing development checkouts and their changes.

**Observed gap:** Bento's initial preflight stopped because it requires a client-matched `version.dll`. The team's workflow builds that from a private loader repository and obtains module references through a configured package source. Those inputs were unavailable for this 48146 attempt. See [bento-preflight.log](.local-build-attempt/2026-10-28/bento-preflight.log).

### C3. Download and verify the actual team archive

```powershell
curl.exe --fail --location --output .local-build-attempt/2026-10-28/team-47965.7z `
  'https://mirror.sp-tushonka.com/builds/SPT-BLEEDINGEDGEMODS-5.0.0-47965-8b1e800-20261010.7z'
```

The downloaded file is 632,896,601 bytes. Its MD5, encoded as Base64, was verified against the user-supplied announcement: **`zdoTnHb8XwQ/VqYc09VYSg==`**. Only after verification was it extracted with 7-Zip into `team-47965` under the experiment directory.

**Why/origin:** use an identifiable official donor for runtime dependencies. This archive does not make the 48146 installation official. Its `BepInEx/core` DLLs were compared with clean Bento v0.2.6 assets and matched byte-for-byte.

### C4. Adapt the newer official loader, with explicit guards

Codex disassembled the verified archive's loader and independently checked its signature matches against the copied 48146 GameAssembly. This donor is **34,304 bytes**, distinct from Antigravity's older 191,488-byte donor.

```powershell
python .local-build-attempt/2026-10-28/port_loader.py
```

The [script](.local-build-attempt/2026-10-28/port_loader.py) checks both input SHA-256 hashes, requires exactly one match for each embedded native patch signature, checks for scratch space, validates the original comparison instruction bytes, then changes only these operands:

| File offset | Check | Original | Replacement |
| --- | --- | --- | --- |
| `0x2720` | GameAssembly PE timestamp | `0x6AC68DE3` | `0x6ACFE9AB` |
| `0x2727` | GameAssembly PE image size | `0x0673A000` | `0x0796C000` |

The four signature RVAs are `0x529D50`, `0x528D90`, `0x5E3BB0`, and `0x529C3E`; scratch RVA is `0x57ABA11`. Output: `version-48146-experimental.dll`, SHA-256 `2987A5C1AA5D7EA5D4975A0B52EA12A0C914EEB04B769FDB3CF81067F693813B`. Full details: [loader-port-report.json](.local-build-attempt/2026-10-28/loader-port-report.json).

**Why/origin:** experimental binary adaptation because matching loader source/output was unavailable. Pattern matches and version-check edits do **not** prove all loader behavior is compatible. This remains the principal unsupported part of the build.

### C5. Apply the launcher's metadata delta to the new installation

The small [MetadataPatch utility](.local-build-attempt/2026-10-28/MetadataPatch/Program.cs) references `SharpHDiffPatch.Core` 2.3.0, the launcher's dependency, and applies the pinned launcher's existing delta:

```powershell
dotnet run --project .local-build-attempt/2026-10-28/MetadataPatch -c Release -- `
  'C:\sptarkov\SPTarkov 5.0.0-local\EscapeFromTarkov_Data\il2cpp_data\Metadata\global-metadata.dat' `
  '.local-build-attempt/2026-10-28/launcher/SPTushonka.Core/SPT_Data/Launcher/Patches/SPT-core/EscapeFromTarkov_Data/il2cpp_data/Metadata/global-metadata.dat.delta' `
  '.local-build-attempt/2026-10-28/global-metadata.dat'
```

Result: 32,118,848-byte patched metadata. The original was preserved as `global-metadata.original.dat` in the experiment directory; the patched file was copied into the **new installation only**. Before normal launcher use, the original was also placed at `global-metadata.dat.spt-bak` beside the target metadata, matching the launcher's backup convention.

**Why/origin:** use the team's existing delta and patch library before reference generation. The invocation utility is local glue; it does not invent a replacement metadata format. It refuses to overwrite its output, so rerunning requires a new output filename.

### C6. Generate references through BepInXDX's own first-launch path

Copy the verified team's `dotnet`, `winhttp.dll`, `doorstop_config.ini`, `.doorstop_version`, and license into the new installation; copy `BepInEx/core`, `config`, and `unity-libs` into its BepInEx folder. Install the experimental loader and patched metadata. Create an empty `BepInEx/plugins/sptushonka` directory, which the loader requires to recognize an SPT installation. Preserve the copied live doorstop configuration in the experiment directory.

Start the copied `EscapeFromTarkov.exe` with `-logFile` pointing at `bootstrap-unity.log` inside the new installation. **This bootstrap loads no modules or prepatcher and is only for reference generation, not gameplay.** BepInXDX runs its own Cpp2IL and Il2CppInterop pipeline before loading patchers/plugins.

**Observed result:** 169 generated interop DLLs, two xref databases, and `assembly-hash.txt`. The first cache hash was `57dbd3783815ae8345a7caf4de786f35`. Logs: [bootstrap-bepinex.log](.local-build-attempt/2026-10-28/bootstrap-bepinex.log), [bootstrap-loader.log](.local-build-attempt/2026-10-28/bootstrap-loader.log).

Copy `BepInEx/core` and `BepInEx/interop` into `reference-package/BepInEx` under the experiment directory. This is the local reference package supplied to Bento. **No Antigravity InteropGenRunner, old generated references, or patched modules were used.**

### C7. Observe the first modules failure and update the responsible dependency

The first Bento build compiled server and launcher but failed to compile modules with three errors: missing `ManagedArguments`, a missing System.Type conversion, and a missing lambda conversion. See [modules-first-failure.log](.local-build-attempt/2026-10-28/modules-first-failure.log).

**Cause supported by source inspection:** current modules consume APIs and generated overloads added to Il2CppInterop after the October 10 runtime. A successful reference-generation run did not make those older references suitable for current modules.

Build the pinned public Il2CppInterop source:

```powershell
dotnet build .local-build-attempt/2026-10-28/Il2CppInterop/Il2CppInterop.Generator/Il2CppInterop.Generator.csproj `
  -c Release -f netstandard2.1 -p:GeneratePackageOnBuild=false
dotnet build .local-build-attempt/2026-10-28/Il2CppInterop/Il2CppInterop.HarmonySupport/Il2CppInterop.HarmonySupport.csproj `
  -c Release -p:GeneratePackageOnBuild=false
```

Both succeeded with upstream warnings. Copy exactly these build outputs into both the target `BepInEx/core` and the isolated Bento `assets/il2cpp/BepInEx/core`:

- `bin/Il2CppInterop.Common/netstandard2.0/Il2CppInterop.Common.dll`
- `bin/Il2CppInterop.Generator/netstandard2.1/Il2CppInterop.Generator.dll`
- `bin/Il2CppInterop.Runtime/net10.0/Il2CppInterop.Runtime.dll`
- `bin/Il2CppInterop.HarmonySupport/net10.0/Il2CppInterop.HarmonySupport.dll`

Preserve the first generated directory as `interop-team-first-launch`, then start another bootstrap with no cached interop directory. This forces regeneration despite unchanged assembly version numbers. Result: 169 DLLs, cache hash `d9c2c5bbf9c59411a780de58889014f9`. Preserve the first reference package as `reference-package-team`; populate a fresh `reference-package` from the updated target core/interop. [reference-inventory.json](.local-build-attempt/2026-10-28/reference-inventory.json) records every file's SHA-256.

The unmodified modules now build successfully: **0 errors, 2 warnings**. See [modules-current-build.log](.local-build-attempt/2026-10-28/modules-current-build.log).

**Why/origin:** a demonstrated dependency mismatch, resolved by building public dependency source. BepInXDX and the private Cpp2IL binaries remain the team's shipped versions. This attempt did not need Antigravity's Cpp2IL csproj reference replacement or complete BepInXDX rebuild. BepInXDX's repository does document local dependency feeds; the private Cpp2IL source is an accessibility limitation, not an absence of all dependency instructions.

### C8. Package with Bento and install with 7-Zip

```powershell
dotnet run --project .local-build-attempt/2026-10-28/bento/Bento.csproj -c Release -- `
  --no-config --version 5.0.0 --build-type BLEEDINGEDGEMODS `
  --server .local-build-attempt/2026-10-28/server-csharp `
  --modules .local-build-attempt/2026-10-28/modules `
  --launcher .local-build-attempt/2026-10-28/launcher `
  --module-package .local-build-attempt/2026-10-28/reference-package `
  --version-dll .local-build-attempt/2026-10-28/version-48146-experimental.dll `
  --output .local-build-attempt/2026-10-28/dist
```

**Result:** Bento succeeded and produced `SPT-BLEEDINGEDGEMODS-5.0.0-48146-bd58e5ec4-20261029.7z`, 677,461,094 bytes, 2,786 files, MD5/Base64 `nyL2KVkN+E2dPJZXoVyhpA==`.

```powershell
& 'C:\Program Files\7-Zip\7z.exe' x `
  '.local-build-attempt/2026-10-28/dist/SPT-BLEEDINGEDGEMODS-5.0.0-48146-bd58e5ec4-20261029.7z' `
  '-oC:\sptarkov\SPTarkov 5.0.0-local' -y
```

Evidence: [manifest.json](.local-build-attempt/2026-10-28/dist/manifest.json), [bento-current-build.log](.local-build-attempt/2026-10-28/bento-current-build.log). Bento's tag is v0.2.6 but its project still stamps `bentoVersion: 0.2.5`. The launcher is marked dirty because its build rewrites tracked generated version/MudBlazor files; no launcher logic was edited. Modules and server are marked clean. The manifest does not inventory the four dependency replacements, so retain this README and the reference inventory with it.

### C9. Test server startup and isolate a separate seasonal-event failure

Start `SPT_Runtime/SPT.Server.exe` with **SPT_Runtime as its working directory**. The first startup failed in `SeasonalEventService.AddEventGearToBots`: `The given key 'bear' was not present in the dictionary`, while enabling Halloween for the current date.

Preserve `SPT_Runtime/SPT_Data/configs/seasonalevents.json` as `seasonalevents.original.json` in the experiment directory, then change only:

```json
"enableSeasonalEventDetection": false
```

Restart the experimental server. It reports `Server has started, happy playing`, listens on `https://127.0.0.1:6969`, and answers `/launcher/v2/ping` with `Pong!`.

**Why/origin:** local configuration workaround for an observed server startup failure, unrelated to loader/reference generation. It disables automatic seasonal events for this installation; it is not included in the archive from C8. Logs: [original failure](.local-build-attempt/2026-10-28/server-startup-stdout.log), [successful startup](.local-build-attempt/2026-10-28/server-current-stdout.log).

### C10. Start an unpatched client against a fresh test profile

The Windows UI automation helper was unavailable (`native pipe ... cannot find the file`), so Codex used the launcher's local HTTP protocol and launch arguments for a startup smoke test.

1. Follow the launcher's `SetupGameFiles` cleanup list **only in the new target**. Instead of deleting, move existing `BattlEye`, `Logs`, `ConsistencyInfo`, `EscapeFromTarkov_BE.exe`, `Uninstall.exe`, `UnityCrashHandler64.exe`, `WinPixEventRuntime.dll`, and `EscapeFromTarkov_Data/Plugins/x86_64/hwecho.dll` into `launcher-cleanup-backup` in the experiment directory. Verify each resolved source path is inside the target before moving it.
2. Use [local_server_probe.py](.local-build-attempt/2026-10-28/local_server_probe.py) to register a fresh **LocalBuildTest / Standard** profile through `/launcher/v2/register`. This helper only connects to localhost and handles the launcher's zlib request/response protocol.
3. Retrieve its profile ID through `/launcher/v2/profile` and start the new target's EXE with the launcher's arguments: `-force-gfx-jobs native -token=<profile ID> -config={'BackendUrl':'https://127.0.0.1:6969','Version':'live','MatchingVersion':'live'}`. Add `-logFile` pointing at the target's `client-test-unity.log`.
4. Write launcher settings under this installation's `SPT_Runtime/user/Launcher` with the explicit new game path and preferred test profile. Preserve the original metadata `.spt-bak` as described in C5 so future normal launcher patching has the correct input.

**Observed so far:** the prepatcher restored 38 gated exports with 0 failures, resolved System.Type, loaded Core/Custom/Debugging/SinglePlayer, and logged `Chainloader startup complete`. The client connected to the new server, requested game configuration/locales/items/profiles, opened its websocket, and logged version `SPT 5.0.0 (BEM) bd58e5 | 1.2.5.0.48146`. First-run missing-settings messages fell back to default settings. A completed raid and absence of the original audio crash have **not** been established.

The installed SinglePlayer DLL has SHA-256 `9FBF28D894FB9ACEA7D232DC85760F4BDF1349CFF05B551FC0552D3663303FC2`. The old installation still has its original patched DLL hash `A80FE8057D5C1278B88BC9DBA9041E99C75EE5A6BF75F724330E02F47183C3C0`. No audio workaround has been added to this independent build.

**Later observation during this same test:** the client requested `/client/tutor-game/profile`, `/client/raid/configuration`, `/client/match/local/start`, and `/client/game/bot/generate`; the process remained responsive. This establishes progress into local-match startup, not a completed raid or a Factory regression pass. There are also winter-controller and bot-configuration fallback messages, so this is not a claim of error-free gameplay. Snapshots: [client-smoke-bepinex.log](.local-build-attempt/2026-10-28/client-smoke-bepinex.log) and [client-smoke-loader.log](.local-build-attempt/2026-10-28/client-smoke-loader.log).

For subsequent launches, run `SPT.Server.exe`, then `SPT.Launcher.exe`, from the new installation's `SPT_Runtime` directory and select **LocalBuildTest** (or create a separate profile). Do not run a second server while this test server is still listening on port 6969. The seasonal-event config change from C9 is required to reproduce this test's startup with these inputs and date.

**User follow-up:** James reported, "seems to run fine. i stopped client". A subsequent process check confirmed the client had exited and the experimental server remained running (PID 59112). This adds hands-on confirmation of apparently normal operation without the audio patch; the report does not specify a Factory test or completed raid, so those checks remain unverified.

### C11. Stop the server and import the existing save

At James's request, stop the experimental server and verify it exited. Before importing the save, verify no game, server, or launcher process is running.

Copy `C:\SPT-5.0.0\SPT_Runtime\user\profiles\6ade9760458eb1d96422317f.json` into the new installation's `SPT_Runtime/user/profiles` directory. This is **JheredParnell, level 8**, reporting SPT 5.0.0 / client 48146. Preserve the source file and the new installation's LocalBuildTest profile. Before copying, back up the destination profiles directory and launcher settings under `SPT_Runtime/user/migration-backups/<timestamp>`.

Verify the copied profile's SHA-256 matches the source, then set the new launcher's preferred local profile to `6ade9760458eb1d96422317f`. No save contents were edited and no other old-installation files were migrated. Loading this imported profile in the new client remains to be tested.

Migration backup: `C:\sptarkov\SPTarkov 5.0.0-local\SPT_Runtime\user\migration-backups\20261028-214256` (destination profiles and launcher settings). The source and copied profile matched SHA-256 `D5D0B70665DD4504EDEF2F8514CD271759FF8830B962154144C9840A2DE96EC5` at import time. Normal subsequent server activity can change the destination save, so this is an import-time checksum, not a permanent expected hash.

### C12. Build and install Deminvincibility from an existing community port

At James's request, inspect `mods/DemInvincibility`. The original developer's remote only advertised `master` and `3.11`, with no public 5.0 PR. A community fork already contained [SPT 5.0 port commit 156c012](https://github.com/y1ngq1ang/Deminvincibility/commit/156c012800a418a75649c7914825595d50f202c4). Use that commit as the baseline rather than independently repeating its port.

James created `jpeckham/Deminvincibility` on GitHub. Rename the local original remote to `upstream`, set `origin` to his fork, and create/push **spt-5.0-48146** with the community port in its history (a fast-forward from original master). Preserve the community author's commit unchanged.

Published result: [jpeckham/Deminvincibility, branch spt-5.0-48146](https://github.com/jpeckham/Deminvincibility/tree/spt-5.0-48146), local adjustments commit `b81d9978b6d1ae9f4cea47f09e9a780e0ec8dd98`, parent community port `156c012800a418a75649c7914825595d50f202c4`. No pull request was opened against the original author. Additional build/install documentation lives in [the mod README](mods/DemInvincibility/README.md).

The community port already builds against this installation. Local version **3.0.1** restores the original English settings, enum descriptions, and notifications; sets the build-path default to the new installation; records EFT build 48146; and corrects the damage setting's range to allow its intended 100% default. The first startup proved that the inherited maximum of 99 silently clamped the default to 99. No health-patch logic was rewritten beyond what the community port already supplied.

```powershell
dotnet build mods/DemInvincibility/Deminvincibility.csproj -c Release `
  '-p:SPTPath=C:\sptarkov\SPTarkov 5.0.0-local'
```

Build result: **0 warnings, 0 errors**. Copy `mods/DemInvincibility/Build/BepInEx/plugins/Deminvincibility.dll` and its `LICENSE.txt` to `C:\sptarkov\SPTarkov 5.0.0-local\BepInEx\plugins\Deminvincibility`. Final installed DLL SHA-256: `9941FD06B54B6A67C2CCDECED50961FD19D51FD659587A29E784D3288D0DDB4C`; verify it matches the build output.

Back up LocalBuildTest before a brief startup smoke test. Start the new server and client using that test profile. The log confirms `Loading [Deminvincibility 3.0.1]`, successful installation of all five patches (`DestroyBodyPartPatch`, `ApplyDamage`, `ChangeHealth`, `DoFracture`, `Kill`), and `Chainloader startup complete`. Stop both test processes afterward. This does not test in-raid damage protection or the optional inherited second-chance behavior. Evidence: [client log](.local-build-attempt/2026-10-28/deminvincibility-test/client-bepinex.log) and [build log](.local-build-attempt/2026-10-28/deminvincibility-build.log).

After the config-only range correction, rebuild and replace the DLL, then verify the compiled range maximum is 100 and exercise BepInEx's actual ConfigFile/AcceptableValueRange behavior: default 100 remains 100, 101 clamps to 100, and 0 clamps to 1. Set the newly generated installed config's damage percentage to 100, preserving its initial version in the test evidence directory. **1 HP Mode and second-chance protection remain off by default**; enable the desired option in F12 under Deminvincibility. The old installation is unchanged.

### C13. Import live key bindings and control settings

James asked whether a mod or launcher feature could import live bindings. Source inspection found a `LoadLiveSettings` implementation in [TroubleshootingPanelComponent.razor](launcher/SPTushonka.Launcher/Components/Settings/TroubleshootingPanelComponent.razor), but its button is explicitly `Disabled="true"` in this launcher revision. The implementation copies the entire live settings directory. No mod is needed to copy only the controls file.

On James's instruction, with the SPT client confirmed closed, copy:

| Purpose | Path |
| --- | --- |
| Live source | `%APPDATA%\Battlestate Games\Escape from Tarkov\Settings\Control.ini` |
| SPT destination | `C:\sptarkov\SPTarkov 5.0.0-local\SPT_Runtime\user\sptSettings\Control.ini` |
| Previous SPT controls backup | `C:\sptarkov\SPTarkov 5.0.0-local\SPT_Runtime\user\migration-backups\controls-20261028-215418\Control.ini` |

Both files had the same top-level schema: `Version`, axis inversion, mouse/aiming/optic sensitivity, double-click timeout, `axisBindings`, and `keyBindings`. Copy only `Control.ini`, then verify the source and destination SHA-256 hashes match. Verification passed. Live settings were not modified; graphics, sound, PostFX, and other SPT settings were not copied or replaced. This imports mouse/control preferences as well as key bindings.

Equivalent repeatable commands (close the client first; use a fresh backup directory):

```powershell
$source = Join-Path $env:APPDATA 'Battlestate Games\Escape from Tarkov\Settings\Control.ini'
$destination = 'C:\sptarkov\SPTarkov 5.0.0-local\SPT_Runtime\user\sptSettings\Control.ini'
$backupDir = 'C:\sptarkov\SPTarkov 5.0.0-local\SPT_Runtime\user\migration-backups\controls-' + (Get-Date -Format 'yyyyMMdd-HHmmss')
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Copy-Item -LiteralPath $destination -Destination (Join-Path $backupDir 'Control.ini')
Copy-Item -LiteralPath $source -Destination $destination -Force
if ((Get-FileHash -LiteralPath $source).Hash -ne (Get-FileHash -LiteralPath $destination).Hash) {
    throw 'Copied controls failed hash verification'
}
```

To undo the import, close the client and copy the backed-up `Control.ini` over the destination. The launcher itself was not modified to enable its disabled import button.

### C14. Codex OpenSesame port and installation

James requested the same fork/branch/port/install workflow for `dwesterwick/SPTOpenSesame`. This is separate from Antigravity's build work and Deminvincibility's community port.

1. Checked upstream branches, PRs, and three listed forks: found SPT 4.1 work but no public 5.0 port. Cloned into `mods/SPTOpenSesame` at upstream commit `86e785d60e636adb08f34ca9366baef616f70e91`.
2. Created `https://github.com/jpeckham/SPTOpenSesame`, renamed the original remote to `upstream`, set `origin` to James's fork, and created branch `spt-5.0-48146`. No upstream PR was opened.
3. Original build failed for missing .NET Framework 4.7.1 targeting pack. Regardless of that pack, the old BepInEx 5/Mono code required conversion for this installation. This was a mod migration, not a missing SPT build-process workaround.
4. Converted the project to .NET 10 and IL2CPP BasePlugin, updated the SPT patch namespace, registered the power-switch component with its native constructor, replaced the managed logger's native singleton, used a native action list and loot-container cast, and inserted translations into EFT.Locale individually. Fixed action-list initialization when Do Nothing is disabled or an existing state has a null list. Preserved resources and upstream interaction behavior, including switch feature gating. Fork version: 4.0.0.
5. Built using `dotnet build mods/SPTOpenSesame/SPTOpenSesame.csproj -c Release` and `dotnet build mods/SPTOpenSesame/tests/RuntimeTests.csproj -c Release`. Default SPTPath is `C:\sptarkov\SPTarkov 5.0.0-local`; override with `'-p:SPTPath=your installation path'`. References come from that initialized installation. Build passed with 0 errors and 9 CS8981 warnings for upstream's generated lowercase locale classes.
6. Confirmed client/server stopped and backed up LocalBuildTest into `.local-build-attempt/2026-10-28/opensesame-test/test-profile-before.json`. Copied `mods/SPTOpenSesame/Build/BepInEx/plugins/OpenSesame/SPTOpenSesame.dll` into the matching folder under the new installation. Installed SHA-256: `751037743C9B79ABFDFDB7FC9EABEFB4B6629CCB57D7F10E323CC57AFF876311`.
7. Temporarily installed the runtime-test DLL, launched the server and LocalBuildTest client, and verified component registration and all four interaction patches. Runtime checks passed for ten locales, English fallback, null interaction state/list initialization, feature toggle, and native callback execution after managed GC. Evidence: `.local-build-attempt/2026-10-28/opensesame-build.log` and `opensesame-test/BepInEx-LogOutput.log`.
8. Stopped test client/server and removed the test DLL. Production plugin remains installed. `BepInEx/config/com.danw.opensesame.cfg` retains `Enabled Features = All` and `Enabled Debug Messages = 0`, also accessible through F12. To uninstall, close the client and remove `BepInEx/plugins/OpenSesame/SPTOpenSesame.dll`.

The mod README includes build/install and runtime-test reproduction instructions. **Actual in-raid door/keycard/container unlocking, power-switch discovery/use, D2 behavior, and UI language switching remain unverified.** Successful startup and helper tests are not full gameplay validation. No live EFT, old-installation, SPT modules, or runtime component changes were needed for this mod.

### C15. Reusable mod fork, port, build, and install process

This is our local client-mod workflow for **SPT 5.0 / EFT 1.2.5.0.48146** in `C:\sptarkov\SPTarkov 5.0.0-local`. It records the approach used for C12 and C14, separately from Antigravity's build history. It is not an official SPT reference-build procedure.

1. **Find an existing port first.** Inspect the original repository's documentation, branches, PRs, and public forks. Record the source URL and exact commit. Deminvincibility reused y1ngq1ang's community port `156c012`; OpenSesame required our own conversion from upstream `86e785d`. Distinguish missing build prerequisites from runtime/API incompatibility.
2. **Fork and branch.** Create or reuse James's GitHub fork. Keep `upstream` pointing to the original author and `origin` pointing to `jpeckham`. Work in `mods/<repo>` on `spt-5.0-48146`. Inspect existing branches, remotes, and uncommitted changes before modifying an existing checkout. Preserve another developer's port commits and authorship when integrating them. Deminvincibility was a fast-forward from the original source, not a new merge commit.

   For a **new clone**, after creating the GitHub fork, substitute the real names in these commands:

   ```powershell
   git clone https://github.com/<author>/<repo>.git mods/<repo>
   git -C mods/<repo> remote rename origin upstream
   git -C mods/<repo> remote add origin https://github.com/jpeckham/<repo>.git
   git -C mods/<repo> switch -c spt-5.0-48146
   # Only when adopting a verified community port:
   git -C mods/<repo> remote add community https://github.com/<porter>/<repo>.git
   git -C mods/<repo> fetch community
   git -C mods/<repo> merge --ff-only <verified-port-commit>
   ```

   If fast-forward integration fails, review the divergent changes before choosing a merge or cherry-pick. Do not reset away existing work.
3. **Port against the installed runtime.** Reference this installation's `BepInEx/core`, generated `BepInEx/interop`, and SPT plugin assemblies. Our client uses .NET 10, BepInXDX/BepInEx 6 IL2CPP, and `SPTushonka.Reflection.Patching`. Check plugin entry points, native patch targets, injected Unity components, collections, casts, and callbacks where applicable. Preserve upstream features/resources and credit. Explain why each change is needed; distinguish migration work from separate behavior fixes. Do not commit game/reference DLLs or assume another EFT build has identical signatures.
4. **Build and stage.** Build Release, retain the log, and inspect the exit code, errors, and warnings. Both ported projects support the following command with the actual repository/project names substituted:

   ```powershell
   dotnet build mods/<repo>/<project>.csproj -c Release `
     '-p:SPTPath=C:\sptarkov\SPTarkov 5.0.0-local'
   ```

   Install the project's staged production plugin and required assets, not all the referenced game/runtime assemblies.
5. **Back up and install.** Confirm the target client/server are stopped before replacing binaries or backing up the test save. Preserve existing mod files/config and the LocalBuildTest profile in a timestamped backup. Copy the plugin into its folder under the new installation's `BepInEx/plugins`, including required assets and any supplied license. Check for older copies of the same plugin elsewhere. Verify the installed DLL's SHA-256 matches the build output. Record version, destination, hash, and config defaults. Leave live EFT and the old installation alone.
6. **Verify in stages.** Start the server with `SPT_Runtime` as its working directory, then launch LocalBuildTest. Check plugin loading, expected patch installation, and relevant errors in `BepInEx/LogOutput.log`. For native interop changes, use an in-client test harness where useful. Separately test actual behavior in a raid. State exactly what passed and what remains untested: startup does not establish damage protection, door unlocking, or power-switch behavior.
7. **Clean up and publish our branch.** Stop the processes started for testing and remove temporary test DLLs. Verify the production plugin and intended config remain. Review the diff and staged files, excluding game assemblies, credentials, saves, and local logs. Commit the source/documentation and run `git push -u origin spt-5.0-48146`. Publishing to our fork does not open an upstream PR.
8. **Document and retain rollback.** Update both the mod README and this root README with source/port commits, fork/branch, changes and reasons, build command, installation path/hash, backups, settings, test evidence, and limitations. To roll back, stop the client/server and restore the previous mod files/config; for a first installation, remove the new plugin DLL. Restore a save only deliberately, since restoring its backup discards later progress.

| Mod | Fork branch | Baseline and our commit | Installed plugin folder | Detailed record |
| --- | --- | --- | --- | --- |
| Deminvincibility | [jpeckham / spt-5.0-48146](https://github.com/jpeckham/Deminvincibility/tree/spt-5.0-48146) | Community `156c012` → our `b81d997` | `BepInEx/plugins/Deminvincibility` | C12; [mod README](mods/DemInvincibility/README.md) |
| OpenSesame | [jpeckham / spt-5.0-48146](https://github.com/jpeckham/SPTOpenSesame/tree/spt-5.0-48146) | Upstream `86e785d` → our `e47f951` | `BepInEx/plugins/OpenSesame` | C14; [mod README](mods/SPTOpenSesame/README.md) |
| Freecam | [jpeckham / spt-5.0-48146](https://github.com/jpeckham/SPT-Freecam/tree/spt-5.0-48146) | Upstream `fa45a86` → our `770c506` | `BepInEx/plugins/Freecam` | C16; [mod README](mods/SPT-Freecam/README.md) |
| Skipper | [jpeckham / spt-5.0-48146](https://github.com/jpeckham/SPT-Skipper/tree/spt-5.0-48146) | Community `cd2d5bb` → our `1a3d0c9` | `BepInEx/plugins/Skipper` | C17; [mod README](mods/SPT-Skipper/README.md) |
| RaidReview | [jpeckham / spt-5.0-48146](https://github.com/jpeckham/SPT-RaidReview/tree/spt-5.0-48146) | Upstream `2567b37` → our `a053fcd` | `BepInEx/plugins/RaidReview` and `SPT_Runtime/user/mods/RaidReview` | C18; [mod README](mods/SPT-RaidReview/README.md) |

### C16. Codex Freecam port and installation

1. Inspected `acidphantasm/SPT-Freecam`: upstream had only master, no PRs, and the other listed fork had the same master commit. Reused James's existing fork at `https://github.com/jpeckham/SPT-Freecam`. Cloned into `mods/SPT-Freecam`, set original author as `upstream` and James as `origin`, and created `spt-5.0-48146` from `fa45a86d48aa6b9311f9a255b03a82a84be291ba`.
2. Ported version 1.4.8 to our experimental 2.0.0: .NET 10/BepInEx 6 IL2CPP entry point, registered both Unity components with native constructors, updated KeyboardShortcut and patch namespaces, and replaced managed field reflection/injection with generated native properties. The native fall handler returns a float, so suppression explicitly returns zero and checks the local player. Kept original author credit and NCSA license.
3. Added initialization/state guards, prevented controls toggling from entering a partial freecam state, handled paused camera exit/teleport, reset teleport state across raids, restored input/UI on teardown, and corrected teleport yaw from quaternion-component to Euler-angle use. These are local fixes, separate from the runtime migration.
4. Built with `dotnet build mods/SPT-Freecam/project/Terkoiz.Freecam/Terkoiz.Freecam.csproj -c Release '-p:SPTPath=C:\sptarkov\SPTarkov 5.0.0-local'`: **0 warnings, 0 errors**. Replaced upstream's automatic installation/archive post-build actions with local staging. Copy the staged `Terkoiz.Freecam.dll` and `LICENSE` from `project/Terkoiz.Freecam/Build/BepInEx/plugins/Freecam` to the matching folder in the new installation, with client/server stopped.
5. Backed up LocalBuildTest to `.local-build-attempt/2026-10-28/freecam-test/test-profile-before.json`. Started the target server/client with that profile and a temporary runtime harness. Both components registered; `FreecamPatch`, `FallDamagePatch`, and `ForceSetCameraPositionPatch` enabled. Harness passed native component creation, pre-raid update guard, and normal/free/paused camera-reset gating. Evidence: `freecam-test/BepInEx-LogOutput.log` and `freecam-build.log` under the experiment directory.
6. Stopped test processes and removed `Freecam.RuntimeTests.dll`. Rebuilt after formatting/license-staging cleanup (no behavior changes) and installed the production DLL. Final SHA-256: `8C9E4D2838028DFE73ABDC6FEB4B845D136C818F2B8BD9B2E7A73175DCFCF6F2`.

Controls: numpad **+** toggles freecam, **.** toggles detached-camera/player controls, **Enter** teleports, and **\*** toggles UI. F12 configures these in `com.terkoiz.freecam.cfg`. Smart fall prevention defaults on; global fall-damage suppression and remembered camera position default off. **Actual in-raid flight, teleport/fall prevention, UI behavior, and raid lifecycle remain unverified.** No live EFT, old-installation, or SPT runtime changes were required. To uninstall, close the client and remove `BepInEx/plugins/Freecam/Terkoiz.Freecam.dll`.

See [the mod README](mods/SPT-Freecam/README.md) for build/test reproduction and [our fork branch](https://github.com/jpeckham/SPT-Freecam/tree/spt-5.0-48146). No upstream PR is opened by this workflow.

### C17. Build and install Skipper from a community 5.0 port

1. James supplied upstream `acidphantasm/SPT-Skipper` and his existing fork `jpeckham/SPT-Skipper`. Cloned into `mods/SPT-Skipper`, retained the author as `upstream`, set James's fork as `origin`, and checked upstream branches/PRs and the four other listed forks.
2. Found huaxianmfs's SPT 5.0 port. Created `spt-5.0-48146` and fast-forwarded to its **v1** commit `cd2d5bb0cef3ee850df72f56e889995f5c3e3a92`, preserving implementation commit `654e21c` and the original `b133f2cb1e2dafea438181508df8846b3fa97330` history. Selected v1's original trader-objective scope; the newer master adds experimental story skipping/status forcing and warns about broken story progression. That extension was not adopted. The separate Bootleg fork retained a Mono client and added payment/server functionality, so it was not the baseline.
3. Updated to .NET 10 and the new installation's references, version 1.2.0, SPT core dependency, typed native postfix arguments, previous-button cleanup for reused objective rows, and quieter debug logging. Restored ignore rules and replaced automatic install/archive actions with local staging. Excluded the old `project` source tree: its leftover IDE-generated assembly attributes initially caused a duplicate-attribute build error after the community directory migration.
4. Built with `dotnet build mods/SPT-Skipper/Terkoiz.Skipper.csproj -c Release '-p:SPTPath=C:\sptarkov\SPTarkov 5.0.0-local'`: **0 warnings, 0 errors**. With client/server stopped, backed up LocalBuildTest to `.local-build-attempt/2026-10-28/skipper-test/test-profile-before.json`. Copied staged `Build/BepInEx/plugins/Skipper/terkoiz-skipper.dll` and `LICENSE` into the matching folder in the new installation.
5. Built `mods/SPT-Skipper/tests/RuntimeTests.csproj`, installed its test DLL temporarily, and started the target server/client with LocalBuildTest. Confirmed quest-view patch installation, behaviour registration, and Update execution. The harness passed patch-target resolution, native progress getter and UnityEvent callback after managed GC, and the null-objective guard. It used isolated objects and did not intentionally complete any real objectives. Evidence: `skipper-test/BepInEx-LogOutput.log` and `skipper-build.log` under the experiment directory. This launch also reconfirmed loading of the final Freecam DLL.
6. Stopped the test processes, removed `Skipper.RuntimeTests.dll`, and rebuilt/reinstalled after line-ending-only cleanup. Final DLL SHA-256: `3BFE2CC22B9E6ADD4C2E2D5E026CB0783DAA2D5223A3B7C5C5DB16B9ABD8FC37`. License is retained alongside it. No live EFT, old-installation, or SPT runtime changes were required.

Usage: open trader task objectives and hold **Left Ctrl** to reveal SKIP, then accept the confirmation dialog. F12 controls `com.terkoiz.skipper.cfg`. Source defaults are enabled true, always-display false, LeftControl hotkey; installed **Always display Skip button was observed true and preserved**. Actual trader UI behavior, objective completion, and persistence across restart remain unverified. Main-story skipping is not supported by this selected baseline. Uninstalling the plugin does not reverse quest progress already saved; retain profile backups.

See [the mod README](mods/SPT-Skipper/README.md) and [our fork branch](https://github.com/jpeckham/SPT-Skipper/tree/spt-5.0-48146). No upstream PR was opened.

### C18. Codex RaidReview client, server, and web-app port

James supplied `Chazut/SPT-RaidReview` and had already created his fork. This mod has three components, so installation required more than a client DLL.

1. Cloned into `mods/SPT-RaidReview`; checked upstream branches/PRs and the two other listed forks (Tosox and Krelsis). No 5.0 port found. Set `upstream` to Chazut and `origin` to `jpeckham`, then created `spt-5.0-48146` from 4.1.X commit `2567b3729437cf71248bcec607bdfb8f1393828e` (1.9.0). Our client/server metadata uses experimental version **2.0.0**.
2. Ported the client to .NET 10/BepInEx 6 IL2CPP, injected its capture component, wrapped the coroutine, updated patch namespaces/plugin discovery, and used native casts/properties/pointer identity. Updated the shot's shooter-profile access for 48146. Preserved managed JSON/WebSocket transport using packaged dependencies. Bound the optional ORBIT API at runtime to avoid a build dependency on its absent Mono DLL; optional integrations remain unvalidated on 5.0. Changed F5 checking to a per-frame key-down event to avoid repeated tabs while held.
3. Changed server references from SPT 4.1.2 NuGet packages to the new installation's server DLLs and updated compatibility metadata. Retained isolated SQLite dependencies. Builds default to staging without deployment. The frontend's original npm lockfile omitted esbuild platform entries, causing `npm ci` to fail; regenerated those entries with `npm install --package-lock-only --ignore-scripts --no-audit --no-fund`, then successfully ran clean install/build.
4. Built the frontend first, then embedded it in the server and built the client:

   ```powershell
   npm --prefix mods/SPT-RaidReview/Private ci --no-audit --no-fund
   npm --prefix mods/SPT-RaidReview/Private run build
   dotnet build mods/SPT-RaidReview/ServerMod/ServerMod.csproj -c Release -p:SkipDeploy=true `
     '-p:SPTPath=C:\sptarkov\SPTarkov 5.0.0-local'
   dotnet build mods/SPT-RaidReview/Client/RAID-REVIEW.csproj -c Release `
     '-p:SPTPath=C:\sptarkov\SPTarkov 5.0.0-local'
   ```

   Both .NET builds: **0 warnings, 0 errors**. TypeScript/Vite build passed with the large-bundle warning. Build logs: `.local-build-attempt/2026-10-28/raidreview-client-build.log` and `raidreview-server-build.log`.
5. With client/server stopped, backed up LocalBuildTest to `.local-build-attempt/2026-10-28/raidreview-test/test-profile-before.json`. No existing server RaidReview installation was present. Copied the staged client folder into `BepInEx/plugins/RaidReview`, including managed Newtonsoft.Json/websocket-sharp and LICENSE. Deployed the server using `-p:SkipDeploy=false` and explicit `-p:SptModDirectory=C:\sptarkov\SPTarkov 5.0.0-local\SPT_Runtime\user\mods\RaidReview`. Kept SQLite dependencies in `lib/sqlite` and `runtimes/win-x64/native`, not at the mod root; copied LICENSE. Detailed commands are in the mod README.
6. Started the server and LocalBuildTest client. Confirmed SQLite initialization, all **17 client patches**, the capture component, and a successful WebSocket connection. HTTP `/` returned 200 with the embedded frontend and `/api/raids` returned an empty list. Saved initial/final client logs under `raidreview-test/BepInEx-first.log` and `BepInEx-final.log`, with server stdout/stderr beside them.
7. Ran upstream test suites (adapting recording/switch test doubles to native wrapper APIs): RecordingPipeline **1172**, BehaviorDecisions **68**, HeadlessPresentation **45**, SwitchRecording **23**, RaidTransfer **289**, SQLiteIsolation `alone` **14** checks passed. Logs are in `raidreview-test`. Storage/transfer fixtures use temporary directories, not the installed recordings database.
8. Stopped both test processes. Rebuilt/reinstalled after whitespace-only cleanup. Installed SHA-256: client `8F90B6C07B380FD89D1CD98E1A3ECC0E75A4D20BDBCCFD481088A99D9E3F4224`; server `4D8A20E30D99DEF422425BA36E72FA944A35252B22D9435DA596DA72742E5270`. No live EFT, old-installation, or SPT runtime component changes were needed.

Use **F5** in-game or **http://127.0.0.1:7829** with the server running; the recorder connects to WebSocket **7828**. Recording defaults on, server usage telemetry off. Server config defaults retain 30 raids and delete unfinished recordings. Preserve `SPT_Runtime/user/mods/RaidReview/data` and `config` on upgrades. Client settings: `BepInEx/config/ekky.raidreview.cfg`.

**Still unverified:** a completed raid recorded and replayed end to end, event/position correctness, the menu button, and optional AI/Fika integrations. Startup and fixture tests do not establish those gameplay results. To disable, close client/server and move both RaidReview mod folders outside their respective plugin/mod directories while retaining server data/config. See [the mod README](mods/SPT-RaidReview/README.md) and [our branch](https://github.com/jpeckham/SPT-RaidReview/tree/spt-5.0-48146). No upstream PR was opened.

### C19. Freecam 2.0.1: fix competing camera updates

James reported that enabling Freecam with numpad + and holding W repeatedly pulled the camera back. This was the first reported in-raid movement test; C16's startup/helper checks had not exercised that behavior.

Inspected the current native camera methods using a temporary probe. `PlayerCameraController.UpdatePointOfView` dispatches to its active camera state, and its LateUpdate/fixed/update loops continue driving that state. The inherited body-POV trick did not stop these updates, so the original `ForceSetPosition` guard alone did not give Freecam exclusive control.

Changed Freecam to suspend the native `PlayerCameraController` while detached, keeping the player body visible in third person and the separate Freecam component responsible for movement. Paused camera controls retain that suspension; exit/teleport and component teardown restore the previous enabled state. Repeated suspension does not overwrite that saved state. Version is now **2.0.1**.

Added an in-client regression check against a real native camera component. It failed before the fix (`Missing native camera ownership handoff`) and passed afterward for suspend/re-entry/restore and an initially disabled controller. Existing component/guard checks also passed. Build: **0 warnings, 0 errors**. Evidence and old-DLL backup are under `.local-build-attempt/2026-10-28/freecam-leash-test`; see `regression-red.log`, `regression-green.log`, `build.log`, and `Terkoiz.Freecam-2.0.0.dll`.

Installed new DLL SHA-256: `53B6C6DFBAA438DFE4DF9606A7FD51CF2AAFCDA78B7EC01FFEDFA0383552525A`. Pushed fix commit `0b898b4` to the existing fork branch. Removed the temporary runtime test plugin after checking. Test clients were closed; Codex did not stop James's existing server. The final process check found neither client nor server running. **An in-raid retest of numpad + and W remains required to confirm the reported symptom is gone.**

### Handoff status after these follow-up changes

- The new installation is independent of `C:\SPT-5.0.0`; the original save has been imported and backed up. James discussed deleting the old installation for space. Codex did not delete it and recommended checking the imported profile in-game first.
- The independent build, local seasonal-event setting, save import, Deminvincibility installation, and live controls import are separate changes. The original C8 build archive does not include the later config, save, mod, or controls changes.
- Codex stopped its test processes. During this documentation update, a later client/server pair was observed running from the new installation; they were left alone. Earlier statements that the test processes were stopped refer to those specific tests, not the user's subsequent sessions.
- Confirmed: build/package success, client/server startup, user report that it seemed to run fine, save-copy integrity at import, mod patch loading, and controls-copy integrity at import. Factory-specific audio regression, completed-raid validation, imported-profile gameplay, and in-raid Deminvincibility behavior have not been explicitly confirmed to Codex.

### C20. RaidReview 2.0.1: faction labels, player spawn value, and FPS investigation

James reported PMC bots labeled `(scav)`, guards labeled Follower, no human spawn value, and sustained sub-60 FPS throughout Shoreline. These are separate findings; performance is not yet fixed.

1. Read the installed SQLite database using a read-only connection. In raid `d70aeabd-67c5-445f-aac2-38d3409ac668`, nine bots had correct `PMC|USEC`/`PMC|BEAR` roles but team `4` and fallback brain `SCAV`. The human's team was `1`. The UI expects named factions. SPT 5 PMC bots can report Savage at runtime; the port also lacked explicit enum string serialization.
2. Added explicit faction serialization and role-based display normalization on copied player snapshots. The server normalizes response objects for historical raids too. It does not change native player factions or rewrite stored player records. Boss guards remaining `FOLLOWER` is the existing upstream convention, not a port regression.
3. Confirmed the human had zero starting-inventory rows. Upstream captured only AI inventory. Extracted the capture routine, enabled it for all players, and called it at main-player registration as well as discovery of other participants. This captures future raids only; the missing starting value of an old raid cannot be reliably reconstructed from the current save. Existing UI price/quantity and slot rules remain unchanged.
4. Added regression checks: faction tests failed before normalization; human inventory capture failed while retaining the AI-only guard, then passed after removal. Six suites passed: RecordingPipeline 1182, HeadlessPresentation 56, BehaviorDecisions 68, SwitchRecording 23, RaidTransfer 289, SQLiteIsolation 14. Client/server Release builds passed with zero warnings/errors.
5. Backed up the actual database `SPT_Runtime/user/mods/RaidReview/data/raid_review_mod.db` using SQLite's backup API, plus installed DLLs and client config, under `.local-build-attempt/2026-10-28/raidreview-faction-test`. With game/server stopped, copied the new client and server DLLs into their existing mod folders. Preserved recordings, dependencies, and server configuration. Set client `Performance logging = true`.
6. Started a test server and requested the linked raid API. Verified all nine PMC factions/brains, preserved all four Sanitar guards as Followers, and compared the original database player rows byte-for-byte after JSON encoding: unchanged. Started LocalBuildTest and confirmed RaidReview 2.0.1 loaded, patches enabled, and WebSocket connected. Saved `raid-api.json`, startup logs, and pre-test profile in the evidence folder. Stopped both test processes. New player inventory capture still needs a real raid check.

Installed SHA-256: client `A4D5972C297ADB995AAED032EF1C08DB352C83370A779F6F28CE28D664BF1BC8`; server `03AB1B4B14D9C4E9AFC01A85D38F6D87240514CABC288BB21B8C43CB2E0FE0C6`.

**FPS investigation remains open.** The client uses a 5 Hz capture coroutine, event hooks for combat/loot, and a worker for serialization/WebSocket sending. Prior gameplay logs have no RR performance samples because that setting was off. Added separate timing/allocation stages for loose loot, spawn inventory, and individual participants alongside the existing capture/ballistics/loot/queue measurements. Timings overlap (Participant and SpawnInventory can be inside Capture); do not add them together. Managed allocation counters do not measure native IL2CPP allocations. Startup testing cannot establish in-raid FPS.

Next diagnostic run: enter Shoreline, reproduce the slowdown for at least 60 seconds, then exit and preserve `BepInEx/LogOutput.log` before launching again. `[RR-PERF]` reports every ten seconds. For an optional same-raid comparison, use F12 > Raid Review > Enable Recording = false, close F12, and compare FPS for 30 seconds in the same location. This finalizes the recording; re-enabling starts recording only in the next raid. Restore the setting before the next raid. A full restart with the client plugin removed may still be needed to isolate native patch overhead if disabling capture does not help. No unmeasured performance improvement is claimed. Freecam 2.0.1's movement fix from C19 also still needs James's in-raid retest.

### C21. Measured RaidReview overhead and Freecam 2.0.2 follow-up

James completed a roughly ten-minute Shoreline raid, reporting occasional ~80 FPS but still lower-than-normal performance. Freecam 2.0.1 traveled farther but still leashed. Preserved the gameplay log before any test launch in `.local-build-attempt/2026-10-28/raidreview-performance-followup/user-raid.log` and generated `performance-summary.json` from all 60 RR-PERF reports.

- Capture consumed 651.77 ms total across ~600 seconds. After the first 30 seconds, median average capture cost was 0.175 ms per tick at roughly 5 Hz. The worst later tick was 4.89 ms. The first capture spiked to 130.05 ms; the first window included 46.88 ms of loose-loot capture and 55.67 ms of bot spawn inventories. Nested timings overlap and must not be added together.
- No dropped packets; queue depth at reporting times was at most 2 (lifetime peak reached 6). Frame-count/time differences between reports imply window-average FPS ranging ~51–92, median ~63. These are not instantaneous FPS or 1% lows.
- The measured collector cost does not explain sustained low FPS. Native patch trampoline overhead, native allocations, rendering, browser/server work and other game systems are not fully covered by these counters. No performance fix was claimed or sampling rate reduced. A controlled same-location recording-off comparison, then a full client restart without the RaidReview client plugin if needed, is the next isolation step. The old report's improvement is not evidence that 2.0.1 fixed performance.
- Read-only database inspection confirmed raid `4b58d2a6-c52b-4fa6-be39-99ddaf047733` contains 66 player starting-inventory rows; the previous raid had zero. This verifies actual gameplay inventory capture. The UI's excluded-slot rules still determine the displayed spawn value.

Freecam inspection identified another vulnerability: movement read the shared camera transform each frame, allowing any external transform reset or parent movement to contaminate the next movement origin even with PlayerCameraController disabled. The exact remaining in-game writer has not been identified. Version **2.0.2** stores an independent world position/rotation, restores it before input, in LateUpdate, and before camera culling, and keeps ownership while controls are paused. Exit/teleport/teardown release ownership; teleport restores the stored pose before reading its destination. Mouse rotation now uses world angles consistently with stored world pose. Native-controller suspension remains in place.

Added a regression test that failed on 2.0.1 for missing independent pose ownership. The new native-component harness passed 20 simulated external resets and moving-parent changes, paused Update restoration, LateUpdate/pre-cull restoration, release, and the existing suspension/reset guards. Release build passed with zero warnings/errors. The harness invokes render callbacks explicitly; it is not a substitute for an actual raid proving the leash is gone.

Backed up the installed 2.0.1 DLL in the evidence folder and installed 2.0.2 into `BepInEx/plugins/Freecam`. Red/green logs are `freecam-red.log` and `freecam-green.log`. Test clients were launched only as native-component hosts without a backend; backend/session errors in those logs are unrelated to the harness. Both were closed and the temporary test DLL removed. No user server was stopped. In-raid Freecam retest remains required.
