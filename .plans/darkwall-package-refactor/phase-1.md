# Phase 1 — Discovery and Safeguards

## Refactor Summary

**What**: Split `darkwall-windsurf` into two concerns:
1. **Package** (nix store): Binary + icons + desktop entry
2. **Home-manager** (user home): Dotfile symlinks → repo

**Why**: Current design bakes dotfiles into immutable nix store, requiring rebuild on every change.

**Pain Points**:
- Edit workflow file → must rebuild entire package
- Symlinks point to store, not repo
- Package does too much (binary + config management)

---

## Success Criteria

| Before | After |
|--------|-------|
| Edit dotfile → rebuild package | Edit dotfile → instant (symlink to repo) |
| Package installs dotfiles | Home-manager installs dotfiles |
| 500+ line package.nix | Clean ~150 line package.nix |

---

## Current Architecture

```
packages/darkwall-windsurf/
├── default.nix          # 250 lines - does EVERYTHING
│   ├── Fetches windsurf binary
│   ├── Creates desktop entries
│   ├── Installs icons
│   ├── Copies dotfiles to store
│   └── Wrapper script that "installs" dotfiles at runtime
└── dotfiles/
    ├── mcp_config.json
    ├── global_rules.md
    └── workflows/*.md

home/vince/default.nix   # Currently just lists packages
```

## Target Architecture

```
packages/darkwall-windsurf/
├── default.nix          # ~150 lines - ONLY binary/icons/desktop
└── dotfiles/            # Still here, but NOT baked into package
    ├── mcp_config.json
    ├── global_rules.md
    └── workflows/*.md

home/vince/default.nix   # Manages dotfile symlinks
home/vince/windsurf.nix  # NEW: windsurf-specific home config
```

---

## Behavioral Contracts

### Must Preserve

1. `darkwall-windsurf` command works
2. `windsurf` symlink works
3. Desktop entry appears in app menu
4. Icons display correctly
5. Dotfiles end up in `~/.codeium/windsurf/`

### Acceptable Changes

1. Dotfiles are symlinks instead of copies
2. Home-manager activation required (not just package install)

---

## Files to Modify

| File | Change |
|------|--------|
| `packages/darkwall-windsurf/default.nix` | Remove dotfiles logic |
| `home/vince/default.nix` | Import windsurf.nix |
| `home/vince/windsurf.nix` | NEW: dotfile symlinks |
| `home/vince/standalone.nix` | Same changes for Fedora |

---

## Open Questions

### Q1: Where should dotfiles live?

**Options:**
A. Keep in `packages/darkwall-windsurf/dotfiles/` (current)
B. Move to `dotfiles/windsurf/` at repo root
C. Move to `home/vince/windsurf/dotfiles/`

**Recommendation:** A - Keep with package, symlink from home-manager

### Q2: How to handle standalone (Fedora) case?

Home-manager on Fedora also has `mkOutOfStoreSymlink`. Same approach works.

---

## Next Steps

Proceed to Phase 2: Structural Extraction
