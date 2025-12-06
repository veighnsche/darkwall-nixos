# TEAM_426: Shell configuration for vince
{ config, pkgs, lib, ... }:

{
  # ════════════════════════════════════════════════════════════════
  # ZSH
  # ════════════════════════════════════════════════════════════════
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    initContent = ''
      # Autosuggestion color (WCAG-compliant on dark background)
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#94a3b8'

      # History behavior
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_REDUCE_BLANKS
      setopt SHARE_HISTORY
      setopt APPEND_HISTORY
    '';

    shellAliases = {
      ll = "eza -alh";
      ls = "eza";
      la = "eza -a";
      lt = "eza --tree";
      gs = "git status";
      gd = "git diff";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline -20";
      cat = "bat";
      ping = "prettyping --nolegend";
    };

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";  # Overridden by Starship
      plugins = [
        "git"
        "sudo"
        "command-not-found"
        "colored-man-pages"
        "history"
      ];
    };
  };

  # ════════════════════════════════════════════════════════════════
  # Starship Prompt
  # ════════════════════════════════════════════════════════════════
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      palette = "darkwall";
      palettes = {
        darkwall = {
          bg = "#1a1a1a";
          fg = "#e0e0e0";
          accent = "#7aa2f7";
          error = "#f7768e";
          subtle = "#565f89";
        };
      };
      format = "$hostname$all";
      hostname = {
        ssh_only = true;
        format = "[$hostname](fg:accent) ";
      };
      character = {
        success_symbol = "[❯](fg:accent)";
        error_symbol = "[❯](fg:error)";
      };
      battery.disabled = true;
    };
  };

  # ════════════════════════════════════════════════════════════════
  # Zoxide (smart cd)
  # ════════════════════════════════════════════════════════════════
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # ════════════════════════════════════════════════════════════════
  # Direnv
  # ════════════════════════════════════════════════════════════════
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
