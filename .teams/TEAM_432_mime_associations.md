# TEAM_432: MIME Association Bug

## Bug Report

**Symptom:** Firefox and Windsurf don't have MIME associations - clicking links or files doesn't open them in the correct application.

## Root Cause

`xdg.mimeApps` is not configured in home-manager. The XDG config only enables `userDirs` but not `mimeApps`.

## Fix

Add `xdg.mimeApps` configuration to `home/common/default.nix` with:
- Firefox as default browser (http/https URLs, HTML files)
- Windsurf as default for code/text files

## Status

- [x] Root cause identified
- [ ] Fix applied
