# SPT 5.0 / EFT 1.2.5.0.48146 preserved baseline

Recorded 2026-10-29 (America/Chicago). This is the existing custom build, not a new official SPT release.

Installation: `C:\sptarkov\SPTarkov 5.0.0-BE-1.2.5.0.48146`

Renamed from `C:\sptarkov\SPTarkov 5.0.0-local`; executable reports product version `1.2.5.0-48146-d8a79361`. Launcher GamePath was updated. No matching Desktop/Start Menu/pinned shortcut was found in the scanned locations.

## Mod source checkpoints

All five forks use branch `spt-5.0-eft-1.2.5.0.48146` and annotated tag `baseline-eft-1.2.5.0.48146-2026-10-29`, pushed to James's origin. Original `spt-5.0-48146` branches remain unchanged. The new commits update build paths/documentation only; validation outputs were not deployed over the preserved installed DLLs.

| Repository | Baseline commit | Installed-code source commit before path update |
|---|---|---|
| Deminvincibility | `6bb80e3b236cc8ed8abc35518163a03e9e232283` | `b81d9978b6d1ae9f4cea47f09e9a780e0ec8dd98` |
| SPTOpenSesame | `d46c36c6038a25a5330f45490172f490696cf047` | `e47f95108dadbdeac61d606f763d5c818ce53e00` |
| SPT-Freecam | `2323dd6f30cd1b5b7b159679fb88c6880755453b` | `ecfa1532c5b7dcfb8aee9e9ed13f54780cf220a3` |
| SPT-Skipper | `52a5766295c0ec34f4ac886d201b38be6bb03b60` | `1a3d0c9b7e73c8603facf918f9a4398b62130ceb` |
| SPT-RaidReview | `3c01f679640d99fa5fb45dc253696be8ef1ba644` | `c2f74f72e7857cc9eea025dba314dda8d8dd45c1` |

## Other workspace repositories

All 21 repository heads have a local annotated `workspace-eft-1.2.5.0.48146-2026-10-29` tag. These tags were not pushed to upstream repositories. The tag records HEAD only; dirty state is saved separately.

Repository inventory, remotes, worktree paths and dirty status: [repositories-before.json](../.local-build-attempt/2026-10-29/lock-48146/repositories-before.json). Binary-capable working-tree patches and untracked files are saved under `repositories/` beside it. Bento and Launcher had modified/generated files; they were preserved without committing them into upstream source history.

**Provenance caveat:** workspace HEAD is not necessarily the source of installed binaries. In particular, the main modules checkout still contains the earlier audio-patch branch, while the independent Codex installation used clean modules as described in README C1–C11. Use those build records and installed hashes together; do not rebuild blindly from every workspace HEAD.

## Local recovery evidence

The local checkpoint is `.local-build-attempt/2026-10-29/lock-48146/`:

- `installation-files-before.json`: 14,939 pre-move file paths, sizes and timestamps.
- `binary-sha256.json`: 565 DLL/executable/global-metadata hashes, all verified unchanged after rename.
- `configuration-and-profiles.zip`: client configs, launcher settings, profiles, controls, server configs and RaidReview configuration. These contain private user data; keep local.
- `raid_review_mod.db`: SQLite backup of RaidReview history.
- `repositories/`: tracked working-tree binary patches and untracked files. Apply patches only to the corresponding saved commit; tags alone do not include these changes.
- `mods-locked.json`: final mod branches, commits and tags.
- `verification.txt`: relocation/build verification result.

This is a local checkpoint, not an off-device full backup: large game assets remain in the renamed installation and are inventoried, not copied or individually hashed. Generated reference assemblies remain in that installation and are hashed. Source repositories and their Git objects remain in the workspace. The server and game were not launched during this rename.

## Validation and unresolved issues

Six production projects built with their new default paths. OpenSesame retained nine CS8981 locale warnings; the other five had zero warnings. All had zero errors. Builds stayed in repository staging directories.

- Freecam 2.0.2: native reset regression passed, but actual in-raid leash retest remains open.
- RaidReview 2.0.1: PMC presentation verified and player spawn inventory confirmed in gameplay. Sustained low FPS remains under investigation; capture measurements did not explain it. Performance logging remains enabled.
- Other optional AI/Fika integration limits remain as documented in README.

## Work on the next EFT version

Keep this installation and these version-specific branches for 48146. Create a separate installation and separate branch for the exact new EFT version; do not update the pinned folder in place or repoint these build defaults to the newer installation. Branch/tag names are conventions, not write protection. For rollback, use the baseline tag, saved configuration/profile/database backups, and the preserved installed binaries.

## Parent source-control repository

The workspace is now tracked by `jpeckham/SPT-BE`. All 21 child repositories point to James's forks, with published `spt-5.0-eft-1.2.5.0.48146` branches. The parent pins exact commits; see [the committed source manifest](workspace-48146.json) and [source-control workflow](SOURCE-CONTROL.md). This supplements the earlier local-only checkpoint. Local generated changes and private backups remain excluded. The patcher LFS quota limitation is documented in the workflow.
