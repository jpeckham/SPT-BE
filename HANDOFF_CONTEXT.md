# SP-Tushonka 5.0 (`1.2.5.0.48146`) — Context & Handoff Document

> **How to resume in Antigravity:**
> Open `C:\Users\james\source\repos\SP-Tushonka` as your active workspace in Antigravity (so the agent has native workspace access without needing sandbox bypasses), and say:
> *"Read `HANDOFF_CONTEXT.md` in the workspace root and resume from Phase 2 Step 3 (generating `48146` interop assemblies, building `modules`, and packaging the `48146` SPT 5.0 build)."*

---

## 1. Executive Summary of Where the Upgrade Stands

SP-Tushonka's upgrade to Escape from Tarkov **`1.2.5.0.48146`** is **SPT `5.0.0`**, developed on the `5.0x-dev` / `5.0.x-dev` branches (Unity `2022.3.43f2` IL2CPP + `.NET 10` + `BepInXDX` + `Il2CppInterop`).

### What the Upstream Team Already Completed (Oct 18–24, 2026)
1. **`server-csharp` (`5.0x-dev` @ `c775c3bbe`, Oct 20)**:
   - `Libraries/SPTushonka.Server.Assets/SPT_Data/configs/core.json` already sets `"compatibleTarkovVersion": "1.2.5.0.48146"` (updated in `794b0d5c6` on Oct 18).
   - `Build.props` sets `<SptVersion>5.0.0</SptVersion>`.
   - 112 commits ahead, 0 behind `4.1x-dev`. Includes EFT 1.2 HTTP frame shuffling (`RequestEncryptionUtil`, `SptHttpListener`), binary Lobby WebSocket RPC (`LobbySocketChannel`, `SessionRequestWebSocketHandler`), Story Quests/Endings/Tapes/Variables (`EndingController`, `QuestVariableHelper`), BattlePass (`BattlePassController`), TarCoin Shop + Blazor UI (`TarcoinStoreService`), 1.2 PvE Prestige migrations, `InitialSupportService`, 15 new bot types (Black Division, Scourge Event Lab, VSRF, Wedge), 6 storyline traders, and new locations (`terminal`, `icebreaker`, `laboratory_dark`, `sandbox_start`).
2. **`launcher` (`5.0.x-dev` @ `189774f`, Oct 18)**:
   - Already contains the updated `global-metadata.dat.delta` (~5.97 MB HDiffPatch) for build **`48146`** at `SPTushonka.Core/SPT_Data/Launcher/Patches/SPT-core/EscapeFromTarkov_Data/il2cpp_data/Metadata/global-metadata.dat.delta`.
3. **`Il2CppInterop` (`master` @ `6a04b2c`, Oct 24) & `BepInXDX` (`master` @ `08c2ac0`, Oct 22)**:
   - `Il2CppInterop` (`1.6.8`) fixed 3 critical Unity 2022.3.43f2 IL2CPP crashes (`e174997` on Oct 22: xref scan AV, patched reference-type constructors breaking `BotCreationData`, and pinned string offset), added auto-registration of injected types (`295d6fe`), and added `PassSptInlineMarks` (`[InlinedInto]` attribute + runtime Harmony warnings when patching C++ inlined functions in `GameAssembly.dll`, `c4e9dc8` on Oct 24).
   - `BepInXDX` added `IcedDetour` fallback (`b8104c3`) and rebuilt `DobbyTrampoline` (`dfc2024`) for short functions, plus `NativeCrashLog` (`02748d1`) and UnityDoorstop `4.6.0` (`4e98359`).
4. **`modules` (`5.0x-dev` @ `bb20512`, Oct 24)**:
   - Migrated to `.NET 10` and `BepInXDX` IL2CPP.
   - `SPTushonka.PrePatch` (`ExportRestorer` + `GateDecoder`) dynamically strips BSG's 32-byte token gates from `GameAssembly.dll` exports in memory at startup.
   - 48 `ModulePatch` classes + native x64 byte stubs (`FilesCheckerStubs`, `EnumConverterStubs`) + `PlayerPrefs` internal call hooks (`SaveRegistryLocallyPatches`). Includes 16 Cutscenes/Terminal final mission patches and IL2CPP memory spike fixes.

---

## 2. What We Have Already Done Locally in `C:\Users\james\source\repos\SP-Tushonka`

1. **Checked Out Active 5.0 Branches**:
   - `server-csharp` -> `5.0x-dev`
   - `modules` -> `5.0x-dev`
   - `launcher` -> `5.0.x-dev`
2. **Built & Tested `server-csharp` and `launcher` (`.NET 10.0.302`)**:
   - `launcher/SPTushonka.Launcher.slnx` built cleanly in `Release` (`0 Error(s)`).
   - `server-csharp/server-csharp.slnx` built cleanly in `Release` and **passed all 466 / 466 NUnit tests**.
   - Audited `JsonUnmappedMemberHandling.Disallow` in `JsonUtil.cs` (Debug mode): identified the exact 4 unmapped properties across the 1.2.5 database (`$.config.PDTSettings` in `GlobalConfig` / `globals.json`, `GUNSHOT_HEARING_COEF` in `BotGlobalsHearingSettings` / `pmcbear.json`/`pmcusec.json`/`shooterbtr.json`, `payPro` in `ShopWidgetSettings` / `shop/content.json`, and `quests.json`), then restored `JsonUnmappedMemberHandling.Skip` so `server-csharp` working tree is clean.
3. **Verified Local Live EFT Installation (`1.2.5.0.48146`)**:
   - Located at `C:\Battlestate Games\Escape from Tarkov\EscapeFromTarkov.exe` (`ProductVersion: 1.2.5.0-48146-d8a79361`).
   - `GameAssembly.dll` PE header values for `48146`:
     - `TimeDateStamp` (`peOffset + 8`): **`0x6ACFE9AB`**
     - `SizeOfImage` (`peOffset + 24 + 56`): **`0x0796C000`**
4. **Reverse-Engineered & Verified `version.dll` (`IL2CPP-Loader`) for `48146`**:
   - Extracted `version.dll` (191,488 bytes) from `bento` commit `53a48e6:assets/il2cpp/version.dll` (saved in `C:\Users\james\source\repos\SP-Tushonka\bento\version_47888.dll` / scratch).
   - Disassembled its `.text` section (`0x180001000..0x180004800`) and verified all 4 `GameAssembly.dll` signature patterns (`versiongate` at `0x20410`, `cipher2` at `0x20460`, `fld_lea` at `0x204A0`, `cipher1` at `0x204E0`) against `C:\Battlestate Games\Escape from Tarkov\GameAssembly.dll` (`48146`):
     - `versiongate` (`44 8B C3 48 8D 4C 24 ?? E8 ?? ?? ?? ?? 84 C0 75 07 32 DB E9`): **1 exact match** at RVA `0x529D50`
     - `cipher2` (`0F B6 0C 02 30 08 48 8D 40 01 48 83 EF 01 75 F0`): **1 exact match** at RVA `0x528D90`
     - `fld_lea` (`48 63 C2 48 8D 15 ?? ?? ?? ?? 8B 04 82 89 01 C3`): **1 exact match** at RVA `0x5E3BB0`
     - `cipher1` (`E8 ?? ?? ?? ?? 48 8B 05 ?? ?? ?? ?? 83 78 04 00 0F 8C ?? ?? ?? ?? 81 78 04 00 01 00 00`): **1 exact match** at RVA `0x529C3E`
     - `scratch` (`.rdata` 128-byte zero cave): found at RVA `0x57ABA11`
   - **Porting `version.dll` from `47888` to `48146` requires patching only two 32-bit immediates** in `version.dll` at RVA `0x2A9A` (file offset `0x1E9A`):
     - At `0x180002A9A` (`41 81 F9 B7 97 C3 6A` = `cmp r9d, 0x6AC397B7`): replace `0x6AC397B7` with `0x6ACFE9AB` (`48146` `TimeDateStamp`).
     - At `0x180002AA3` (`3D 00 60 72 06` = `cmp eax, 0x06726000`): replace `0x06726000` with `0x0796C000` (`48146` `SizeOfImage`).
5. **Built Latest `Il2CppInterop` (`1.6.8`) & `BepInXDX` (`6.0.0`)**:
   - Built `Il2CppInterop\Il2CppInterop.sln` (`Release`), producing `Il2CppInterop.*.1.6.8.nupkg` in `Il2CppInterop\bin\NuGet\`.
   - Updated `BepInXDX\Runtimes\Unity\BepInEx.Unity.IL2CPP\BepInEx.Unity.IL2CPP.csproj` to reference `Cpp2IL.Core.dll`, `LibCpp2IL.dll`, `Disarm.dll`, `WasmDisassembler.dll`, `StableNameDotNet.dll`, `AssetRipper.CIL.dll`, `AssetRipper.Primitives.dll`, and `Gee.External.Capstone.dll` from `bento\assets\il2cpp\BepInEx\core\`, and built `BepInEx.Unity.IL2CPP` (`Release`).
   - Built artifacts are ready in `C:\Users\james\source\repos\SP-Tushonka\BepInXDX\bin\Unity.IL2CPP\`.

---

## 3. Exact Next Steps to Resume

### Step 1: Sync Updated `BepInXDX` + `Il2CppInterop` into `bento\assets\il2cpp\BepInEx\core\` and Create `version.dll` for `48146`
1. Copy the newly built DLLs/XMLs from `BepInXDX\bin\Unity.IL2CPP\` (`BepInEx.Core.*`, `BepInEx.Preloader.Core.*`, `BepInEx.Unity.Common.*`, `BepInEx.Unity.IL2CPP.*`, `Il2CppInterop.Common.*`, `Il2CppInterop.Generator.*`, `Il2CppInterop.HarmonySupport.*`, `Il2CppInterop.Runtime.*`, `MonoMod.*`, `0Harmony.dll`, `AsmResolver.*`) into `bento\assets\il2cpp\BepInEx\core\`.
2. Extract `bento` commit `53a48e6:assets/il2cpp/version.dll`, patch the two 4-byte PE check immediates (`0x6AC397B7 -> 0x6ACFE9AB` and `0x06726000 -> 0x0796C000`), and save as `bento\assets\il2cpp\version.dll`.

### Step 2: Generate `BepInEx/interop/*.dll` for EFT `1.2.5.0.48146` & Build `modules` (`5.0x-dev`)
1. Apply `launcher\SPTushonka.Core\SPT_Data\Launcher\Patches\SPT-core\EscapeFromTarkov_Data\il2cpp_data\Metadata\global-metadata.dat.delta` against a copy of `C:\Battlestate Games\Escape from Tarkov\EscapeFromTarkov_Data\il2cpp_data\Metadata\global-metadata.dat` using `SharpHDiffPatch.Core` (just as `FilePatcher.cs` in `launcher` does).
2. Run a small .NET 10 console runner invoking `Cpp2IL` + `Il2CppInteropGenerator` (matching `Il2CppInteropManager.RunCpp2Il()` and `RunIl2CppInteropGenerator()` in `BepInXDX\Runtimes\Unity\BepInEx.Unity.IL2CPP\Il2CppInteropManager.cs`, using `bento\assets\il2cpp\BepInEx\unity-libs\2022.3.43.zip`, `GameAssembly.dll`, and the patched `global-metadata.dat`) to generate `BepInEx\interop\*.dll` for `48146`.
3. Build `modules\Modules.slnx` in `Release` pointing `-p:GameDir` at the directory containing `BepInEx\core` and `BepInEx\interop`.

### Step 3: Assemble & Test the Complete SPT 5.0 (`48146`) Install
1. Copy the built `server-csharp`, `launcher`, `modules` (`BepInEx/patchers/sptushonka-prepatch.dll` and `BepInEx/plugins/sptushonka/*.dll`), `bento/assets/il2cpp/*`, and the `48146`-patched `version.dll` into your target SPT 5.0 folder (e.g., `C:\sptarkov\SPTarkov 5.0.0`).
2. Boot `SPT.Server.exe` and `SPT.Launcher.exe`, launch EFT `48146`, and inspect `tushonka.log` and `BepInEx/LogOutput.log` for any `[InlinedInto]` warnings or missing 4.1 client patches.
