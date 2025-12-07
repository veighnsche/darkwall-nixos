# TEAM_433: Windsurf dotfiles configuration
# TEAM_443: Simplified to symlink entire workflows folder
# TEAM_447: Fixed symlink path to use runtime repo location, not Nix store
# Symlinks point to REPO (not store) for instant updates
{ config, pkgs, lib, ... }:

let
  # TEAM_447: Use the actual runtime path where the repo is bootstrapped
  # NOT flakePath (which resolves to /nix/store/...-source at build time)
  repoPath = "/home/vince/Projects/darkwall-nixos";
  dotfilesPath = "${repoPath}/home/common/darkwall-windsurf/dotfiles";
  mkSymlink = path: config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/${path}";
in {
  home.packages = [ pkgs.darkwall-windsurf ];

  # TEAM_443: Symlink folders where possible, files only when needed
  home.file = {
    ".codeium/windsurf/mcp_config.json" = {
      source = mkSymlink "mcp_config.json";
      force = true;
    };
    
    ".codeium/windsurf/memories/global_rules.md" = {
      source = mkSymlink "global_rules.md";
      force = true;
    };
    
    # TEAM_443: Symlink entire workflows folder - new workflows auto-picked up
    ".codeium/windsurf/global_workflows" = {
      source = mkSymlink "workflows";
      force = true;
    };
  };
}
