# Phase 5 — Hardening and Handoff

## Final Verification Checklist

- [ ] `nix flake check` passes
- [ ] `just vm` builds successfully
- [ ] Package contains ONLY: binary, icons, desktop entries
- [ ] Home-manager creates symlinks to repo (not store)
- [ ] Edit dotfile → change is instant (no rebuild)
- [ ] Windsurf launches and loads config correctly

## Documentation Updates

Update README.md to explain:
- Package vs home-manager split
- How to edit dotfiles (just edit, no rebuild)
- Where dotfiles live

## Handoff Notes

### For Future darkwall-* Packages

Follow this pattern:
1. **Package**: Binary + icons + desktop entry only
2. **Home-manager module**: Dotfile symlinks via `mkOutOfStoreSymlink`
3. **Dotfiles**: Live in `packages/darkwall-<name>/dotfiles/`

### Key Insight

Nix packages are IMMUTABLE. User config should NEVER be baked into packages.
Use home-manager for anything that:
- Changes frequently
- Is user-specific
- Should be editable without rebuild
