# TEAM_444: SELinux fc-cache Link Permission Fix

## Status: ✅ COMPLETE

## Bug Summary

`fc-cache` (fontconfig cache builder) running within Nix sandbox (`init_t` context) is denied `link` permission on files with `default_t` context. This affects font cache generation during Nix builds.

## Root Cause

Existing SELinux policy (`nix-sandbox.te`, `nix-daemon.te`, `nix-full.te`) is missing `link` permission for `init_t` on `default_t:file`. The `link` operation is required when fontconfig atomically replaces cache files (creates temp, links to final name).

## AVC Denial Pattern

```
avc: denied { link } for comm="fc-cache" 
  scontext=system_u:system_r:init_t:s0 
  tcontext=system_u:object_r:default_t:s0 
  tclass=file
```

## Fix Applied

Updated `scripts/fedora/nix-sandbox.te` to add `link` permission to the file class for `init_t` on `default_t`.

## Handoff Checklist

- [x] Policy updated with link permission
- [x] Policy recompiled (.pp file)
- [x] Policy installed via semodule
- [x] fc-cache test passes without AVC denials (0 new denials since 13:34)
