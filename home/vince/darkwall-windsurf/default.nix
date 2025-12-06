# TEAM_430: Windsurf dotfiles configuration
# Symlinks point to REPO (not store) for instant updates
{ config, pkgs, lib, flakePath, ... }:

let
  dotfilesPath = "${flakePath}/packages/darkwall-windsurf/dotfiles";
  mkSymlink = path: config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/${path}";
in {
  # Package (binary only)
  home.packages = [ pkgs.darkwall-windsurf ];

  # Dotfile symlinks to repo
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
