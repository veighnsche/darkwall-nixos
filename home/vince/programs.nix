# TEAM_426: Program configurations for vince
{ config, pkgs, lib, ... }:

{
  # ════════════════════════════════════════════════════════════════
  # Git
  # ════════════════════════════════════════════════════════════════
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Vince Liem";
        email = "vincepaul.liem@gmail.com";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "nvim";
    };
  };

  # Delta (git diff pager)
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
    };
  };

  # ════════════════════════════════════════════════════════════════
  # Konsole (KDE terminal)
  # ════════════════════════════════════════════════════════════════
  programs.konsole = {
    enable = true;
    defaultProfile = "Vince";
    profiles = {
      "Vince" = {
        command = "${pkgs.zsh}/bin/zsh";
        font = {
          name = "Hack Nerd Font";
          size = 11;
        };
      };
    };
  };

  # ════════════════════════════════════════════════════════════════
  # Firefox
  # ════════════════════════════════════════════════════════════════
  programs.firefox = {
    enable = true;
  };
}
