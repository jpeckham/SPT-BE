# SVM local history rewrite — 2026-10-31

At James's request, rewrote the personal-use branch `spt-5.0-eft-1.3.0.0.48484` in `mods/svm-csharp` so functional corrections can be reviewed separately from optional UX changes. The starting point remains upstream `10957bc849dc6be7b4a3de60f63331e954401fbf`.

| Commit | Category | Change |
| --- | --- | --- |
| `b9b45cd` | Fix | Resolve server configuration through the registered GlobalTable service |
| `5f0f4eb` | Maintenance | Ignore nested bin/obj build outputs |
| `0141fb1` | Fix | Notify Boolean setting changes; includes the live WPF binding regression tests |
| `a1b2b93` | Compatibility fix | Block installation of the unported Mono helper in this IL2CPP setup |
| `9d3ce6e` | UX | Replace window-control icons with labeled buttons and tooltips |
| `43fb9cc` | UX | Rename Apply Changes and explain the existing Save/Apply/restart sequence |
| `61ceffc` | UX | Remove Apply's thumbs-up icon |
| `4854120` | UX | Center actions with Apply before the contiguous Save/Load/profile controls |
| `5e6a7ec` | UX | Remove the unfinished Prestige tab |

The three fixes touch separate source areas and do not require the UX commits. The notification changes share one root cause, so all affected models and their regression tests stay together. The optional helper restriction is specific to our IL2CPP setup, not a general fix for older Mono installations. The temporary Apply placement and subsequent correction are represented by one final layout commit rather than two contradictory steps. Parent-repository build/reference adapters remain separate from these SVM source commits.

The original local tip `48dde79c0d5e395341dff190398b566ac229a8ee` is retained at `backup/svm-before-atomic-history-20261031`. Earlier README references to `e8e1988`, `cc728e7`, `bc2e1e3` and `48dde79` describe that preserved history; the table above supersedes them for reviewing the current branch.

Verification: original and rewritten tips both have tree `c1941bfe8eda2cfd615ed8dd950795c732ee973a`, and `git diff --exit-code backup/svm-before-atomic-history-20261031 HEAD` passes. The child working tree is clean. No source behavior changed, no build/install was performed, and the installed Greed hash remains `B16D104C70C82E8373994075E763402E9A4CAD0CB62E1BD86F375E7FEEDF3B6E`. Tests were not rerun because the complete tracked content is identical to the tested pre-rewrite tree. Temporary-index reconstruction and the machine-readable commit map are retained locally under `.local-build-attempt/svm/history-rewrite` (script: `.local-build-attempt/svm/rewrite_history.py`).

The personal-use changes remain local under the existing license restriction. No SVM branch was pushed or force-pushed. Its public fork and the parent submodule pin still identify unmodified upstream; the local checkout intentionally differs from that pin. This organization prepares individual changes for review if the author requests them, without publishing modified source now.
