# Source control for the SPT-BE workspace

The parent repository is https://github.com/jpeckham/SPT-BE. Its 22 child repositories are Git submodules in James's account: 21 forks and the original FreeTarcoins repository. Every submodule entry pins an exact commit; a branch name alone does not determine a checkout. Upstream projects retain their own histories and licenses. The parent MIT license applies to the parent workspace material, not as a replacement for child-project licenses.

## Clone the recorded workspace

Install Git and Git LFS, then run:

```powershell
git lfs install
git clone --recurse-submodules https://github.com/jpeckham/SPT-BE.git
cd SPT-BE
git submodule status
```

To use the preserved 48146 baseline, check out the parent's `baseline-eft-1.2.5.0.48146-2026-10-29` tag and run `git submodule update --init --recursive`. On an existing workspace first commit or back up child changes: switching recorded revisions may conflict with them. Do not use `--remote` when reproducing a pinned baseline.

The fresh clone supplies committed source and documentation, not an installed game. You still need the appropriate legally obtained EFT files, generated references, build prerequisites and local configuration. Historical scripts under `docs/build-48146` contain machine-specific paths and reflect earlier build steps; do not run them indiscriminately. Follow README's separate build histories and baseline caveats.

## Record a change

1. Work on a named branch inside the affected child repository. A fresh submodule checkout normally has detached HEAD; switch/create the intended branch before committing.
2. Commit and push that child to its `origin` (James's fork). Its `upstream` remote points to the original project.
3. From the parent, stage the child path, plus any changed documentation, and commit. This records the new exact child commit.
4. Push the parent only after the child commit is available remotely.

Example for the existing 48146 mod branch:

```powershell
git -C mods/SPT-Freecam switch spt-5.0-eft-1.2.5.0.48146
# Edit and validate; then stage only the intended files inside the child.
git -C mods/SPT-Freecam add <changed-files>
git -C mods/SPT-Freecam commit -m "fix: describe the change"
git -C mods/SPT-Freecam push origin spt-5.0-eft-1.2.5.0.48146
git add mods/SPT-Freecam README.md
git commit -m "chore: update the pinned Freecam revision"
git push origin main
```

Use a separate branch and installation for a newer EFT version. Keep baseline tags fixed. `git pull` in the parent does not automatically update all child working trees; inspect local changes before running `git submodule update --init --recursive`.

## What is local only

The parent's allowlist excludes `.local-build-attempt`, `.gamedir-48146`, `dist`, generated bin/obj files, game binaries, saves, logs and databases. Discord pinned-message notes remain local. The existing local backup folder contains private profiles/configuration and must not be force-added.

Bento has generated runtime binary changes and Launcher has generated/vendor asset changes. These remain visible as dirty child working trees and are preserved in the local 48146 checkpoint, not in the parent's Git commit. Submodule commits do not capture dirty files. The checked-in baseline record distinguishes workspace commits from installed build provenance; the main modules checkout's earlier audio patch is not claimed as the source of the clean installed modules.

## GitHub LFS limitation observed during setup

GitHub rejected a normal push to `jpeckham/patcher` because the responsible account/repository exceeded its LFS budget. Its version branch was instead created from the commit already present in the fork, without uploading new binary assets. Every source commit was verified remotely, but this does not establish LFS-object availability. A fresh recursive checkout may fail while downloading affected LFS assets until that quota issue is resolved. A source-only clone with LFS smudging disabled retains pointer files and cannot substitute for the missing assets in a build.
