# Phase 1 — Discovery

## Feature Summary

**darkwall-installer**: A shared Nix library that provides consistent installation behavior for all `darkwall-*` packages.

### Problem Statement

Each darkwall package needs to:
1. Install dotfiles to user's home directory on first run
2. Update dotfiles when package version is newer
3. Follow a consistent directory structure

Without abstraction, this logic would be duplicated across packages.

### Who Benefits

- Package maintainers: Single place to update installation logic
- Users: Consistent behavior across all darkwall packages
- Future packages: Easy to create new darkwall-* packages

---

## Success Criteria

1. **Consistent Structure**: All `darkwall-*` packages follow the same layout:
   ```
   packages/darkwall-<name>/
   ├── default.nix       # Package derivation
   └── dotfiles/         # Files to install to user home
       └── ...
   ```

2. **Shared Installer**: A `mkDarkwallPackage` function that:
   - Takes a base package and dotfiles config
   - Generates the wrapper with installation hook
   - Handles copy-if-newer logic

3. **Extensible**: Easy to add new installation targets (e.g., different config directories)

---

## Current State Analysis

### How it works today (darkwall-windsurf)

```
packages/darkwall-windsurf/
├── default.nix
└── dotfiles/
    ├── mcp_config.json      → ~/.codeium/windsurf/mcp_config.json
    ├── global_rules.md      → ~/.codeium/windsurf/memories/global_rules.md
    └── workflows/           → ~/.codeium/windsurf/global_workflows/
```

The installation logic is embedded in the `--run` wrapper script.

### What needs abstraction

1. **Dotfile mapping**: Source path → Target path in home
2. **Installation logic**: Copy-if-newer with echo feedback
3. **Directory creation**: Ensure target directories exist

---

## Codebase Reconnaissance

### Files to create

| File | Purpose |
|------|---------|
| `lib/mkDarkwallPackage.nix` | Main library function |
| `lib/default.nix` | Library entry point |

### Files to modify

| File | Change |
|------|--------|
| `flake.nix` | Export `lib` output |
| `packages/darkwall-windsurf/default.nix` | Use `mkDarkwallPackage` |

### Constraints

- Must work with `makeWrapper` from nixpkgs
- Must not break existing package behavior
- Installation must be idempotent (safe to run multiple times)

---

## Open Questions

### Q1: Dotfile mapping format

**Options:**
A. Simple flat mapping: `{ "source" = "target"; }`
B. Structured mapping with options: `{ source = "..."; target = "..."; mode = "copy"; }`
C. Convention-based: All files in `dotfiles/` map to a single target directory

**Recommendation:** Start with (A) for simplicity, extend to (B) if needed.

### Q2: Where should the library live?

**Options:**
A. `lib/mkDarkwallPackage.nix` - Standard Nix convention
B. `packages/lib/` - Keep with packages
C. Inline in flake.nix - Simplest but less modular

**Recommendation:** (A) - Standard convention, easy to find.

### Q3: Should we support multiple installation modes?

**Options:**
A. Copy only (current behavior)
B. Copy + Symlink option
C. Symlink only (for development)

**Recommendation:** Start with (A), add (B) later if needed.

---

## Next Steps

1. Answer open questions (user input needed)
2. Proceed to Phase 2: Design
