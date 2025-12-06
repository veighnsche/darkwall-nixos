# Phase 3 — Migration (Implementation)

## UoW 1: Create home/vince/windsurf.nix

```nix
# TEAM_429: Windsurf dotfiles configuration
# Symlinks point to REPO (not store) for instant updates
{ config, pkgs, lib, flakePath, ... }:

let
  dotfilesPath = "${flakePath}/packages/darkwall-windsurf/dotfiles";
  mkSymlink = path: config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/${path}";
in {
  # Package (binary only)
  home.packages = [ pkgs.darkwall-windsurf ];

  # Dotfile symlinks → repo
  home.file = {
    # MCP config
    ".codeium/windsurf/mcp_config.json".source = mkSymlink "mcp_config.json";
    
    # Global rules
    ".codeium/windsurf/memories/global_rules.md".source = mkSymlink "global_rules.md";
    
    # Workflows (each file)
    ".codeium/windsurf/global_workflows/implement-a-plan.md".source = 
      mkSymlink "workflows/implement-a-plan.md";
    ".codeium/windsurf/global_workflows/investigate-a-bug.md".source = 
      mkSymlink "workflows/investigate-a-bug.md";
    ".codeium/windsurf/global_workflows/make-a-bugfix-plan.md".source = 
      mkSymlink "workflows/make-a-bugfix-plan.md";
    ".codeium/windsurf/global_workflows/make-a-new-feature-plan.md".source = 
      mkSymlink "workflows/make-a-new-feature-plan.md";
    ".codeium/windsurf/global_workflows/make-a-refactor-plan.md".source = 
      mkSymlink "workflows/make-a-refactor-plan.md";
    ".codeium/windsurf/global_workflows/review-a-plan.md".source = 
      mkSymlink "workflows/review-a-plan.md";
    ".codeium/windsurf/global_workflows/review-an-implementation.md".source = 
      mkSymlink "workflows/review-an-implementation.md";
  };
}
```

---

## UoW 2: Strip packages/darkwall-windsurf/default.nix

Remove:
- `dotfilesPath` variable
- `cp -r ${dotfilesPath}/* $out/share/darkwall-windsurf/`
- Entire `--run '...'` script block
- Keep `--prefix LD_LIBRARY_PATH` and `gappsWrapperArgs`

---

## UoW 3: Update home/vince/default.nix

Change:
```nix
imports = [
  ../common
  ./shell.nix
  ./programs.nix
  ./windsurf.nix  # ADD THIS
];

# REMOVE darkwall-windsurf from home.packages (now in windsurf.nix)
```

---

## UoW 4: Update home/vince/standalone.nix

Same pattern - import windsurf config, remove from packages.

---

## UoW 5: Update flake.nix specialArgs

Ensure `flakePath` is passed to home-manager:
```nix
specialArgs = {
  inherit inputs self;
  flakePath = "/home/vince/Projects/darkwall-nixos";  # For mkOutOfStoreSymlink
};
```
