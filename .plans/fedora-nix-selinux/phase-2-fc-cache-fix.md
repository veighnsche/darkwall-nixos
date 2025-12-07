# Phase 2: SELinux fc-cache Link Permission Fix

## Status: ✅ COMPLETE (TEAM_444)

## Root Cause Analysis

### Problem
`fc-cache` is denied `link` system call on files in `/nix/store` during font cache builds.

### Why It Happens
1. `fc-cache` creates temp files (e.g., `*.cache-9.TMP-XXXXX`)
2. It then uses `link()` to atomically replace the cache file
3. These files have `default_t` SELinux context (from `/nix/store`)
4. Existing policy allows `create`, `open`, `read`, `write`, `unlink` but NOT `link`

### Evidence
```
avc: denied { link } for comm="fc-cache" name="...cache-9.TMP-..."
  scontext=system_u:system_r:init_t:s0 
  tcontext=system_u:object_r:default_t:s0 
  tclass=file
```

## Fix Strategy

### Approach: Minimal policy extension
Add `link` permission to the existing `nix-sandbox.te` policy file.

**Before:**
```
allow init_t default_t:file { read write create unlink getattr open };
```

**After:**
```
allow init_t default_t:file { read write create unlink getattr open link };
```

### Reversal Strategy
If fix causes issues:
```bash
sudo semodule -r nix-sandbox
# Or restore previous .pp file
sudo semodule -i scripts/fedora/nix-sandbox.pp.backup
```

## Implementation Steps

1. **Backup current policy**
   ```bash
   cp scripts/fedora/nix-sandbox.pp scripts/fedora/nix-sandbox.pp.backup
   ```

2. **Update .te file** - Add `link` to file permissions

3. **Recompile policy**
   ```bash
   cd scripts/fedora
   checkmodule -M -m -o nix-sandbox.mod nix-sandbox.te
   semodule_package -o nix-sandbox.pp -m nix-sandbox.mod
   ```

4. **Install updated policy**
   ```bash
   sudo semodule -i scripts/fedora/nix-sandbox.pp
   ```

5. **Verify fix**
   ```bash
   # Run a Nix build that uses fc-cache
   nix build --rebuild
   # Check for remaining denials
   sudo ausearch -m avc -ts recent | grep fc-cache
   ```

## Additional Denials Found (From Screenshot)

| Process | Access | Target | Status |
|---------|--------|--------|--------|
| fc-cache | link | file | **FIX THIS** |
| rpc-virtstorage | remove_name | nixos ISO | Low priority (VM cleanup) |
| systemd | write | socket | Already allowed |
| node | create/map/read,write | anon_inode | Unrelated to Nix |
| node | execmem | process | Unrelated to Nix |

The `rpc-virtstorage` denial is a separate issue related to VM/libvirt cleanup - can be addressed in a separate phase if needed.
