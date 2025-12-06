# Phase 4 — Cleanup

## Dead Code Removal

After migration, remove from `packages/darkwall-windsurf/default.nix`:

1. ~~`dotfilesPath` variable~~ (removed in Phase 3)
2. ~~`mkdir -p $out/share/darkwall-windsurf`~~ (no longer needed)
3. ~~`cp -r ${dotfilesPath}/*`~~ (no longer needed)
4. ~~Entire `--run '...'` block~~ (no longer needed)

## Verify Package Size

Before: ~250 lines
After: ~150 lines (just binary + icons + desktop)

## Verify Dotfiles Location

```bash
ls -la ~/.codeium/windsurf/
# Should show symlinks pointing to:
# /home/vince/Projects/darkwall-nixos/packages/darkwall-windsurf/dotfiles/...
```

## Test Instant Updates

1. Edit `packages/darkwall-windsurf/dotfiles/global_rules.md`
2. Open Windsurf
3. Verify change is visible (NO rebuild needed)
