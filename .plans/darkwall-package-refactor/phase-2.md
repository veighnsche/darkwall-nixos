# Phase 2 — Structural Extraction

## Target Design

### Package (default.nix) - ONLY handles:
```nix
{
  # Fetch binary
  src = fetchurl { ... };
  
  # Desktop entries
  desktopItems = [ desktopItem urlHandlerDesktopItem ];
  
  # Icons
  # Install to $out/share/icons/...
  
  # Simple wrapper (just LD_LIBRARY_PATH, NO dotfiles logic)
  makeWrapper ... --prefix LD_LIBRARY_PATH ...
}
```

### Home-manager (windsurf.nix) - handles dotfiles:
```nix
{ config, pkgs, ... }:
let
  # Path to repo (for mkOutOfStoreSymlink)
  flakePath = "/home/vince/Projects/darkwall-nixos";
  dotfilesPath = "${flakePath}/packages/darkwall-windsurf/dotfiles";
  
  mkSymlink = path: config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/${path}";
in {
  home.packages = [ pkgs.darkwall-windsurf ];
  
  home.file = {
    ".codeium/windsurf/mcp_config.json".source = mkSymlink "mcp_config.json";
    ".codeium/windsurf/memories/global_rules.md".source = mkSymlink "global_rules.md";
    # Workflows - each file individually
    ".codeium/windsurf/global_workflows/implement-a-plan.md".source = mkSymlink "workflows/implement-a-plan.md";
    # ... etc
  };
}
```

---

## Extraction Strategy

### Step 1: Create home/vince/windsurf.nix
- New file with dotfile symlinks
- Uses `mkOutOfStoreSymlink` for instant updates

### Step 2: Strip default.nix
- Remove all dotfiles logic
- Remove wrapper `--run` script
- Keep only: binary, icons, desktop entries

### Step 3: Update home/vince/default.nix
- Import windsurf.nix
- Remove darkwall-windsurf from packages list (moved to windsurf.nix)

### Step 4: Update home/vince/standalone.nix
- Same changes for Fedora standalone config

---

## Exit Criteria

- [ ] `nix flake check` passes
- [ ] Package builds without dotfiles logic
- [ ] Home-manager config includes windsurf.nix
- [ ] Symlinks point to repo, not store
