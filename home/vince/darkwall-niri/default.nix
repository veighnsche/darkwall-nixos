# TEAM_442: Phase 3 - Niri configuration
# TEAM_443: Refactored to use symlinks (like darkwall-windsurf)
# TEAM_425: Added build-time niri config validation preflight
# TEAM_447: Fixed symlink path to use runtime repo location, not Nix store
# TEAM_448: Removed activation script workaround, using canonical mkOutOfStoreSymlink
# Config files live in ./dotfiles/ and are symlinked to ~/.config/
{ config, pkgs, lib, ... }:

let
  # TEAM_447: Use the actual runtime path where the repo is bootstrapped
  # NOT flakePath (which resolves to /nix/store/...-source at build time)
  # This enables instant edits without rebuild
  repoPath = "/home/vince/Projects/darkwall-nixos";
  dotfilesPath = "${repoPath}/home/vince/darkwall-niri/dotfiles";
  mkSymlink = path: config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/${path}";

  # TEAM_425: Preflight check - validates niri config at build time
  # Build fails if config.kdl has syntax errors or invalid options
  niriConfigPath = ./dotfiles/niri/config.kdl;
  niriValidation = pkgs.stdenv.mkDerivation {
    name = "niri-config-validation";
    src = niriConfigPath;
    dontUnpack = true;
    nativeBuildInputs = [ pkgs.niri ];
    buildPhase = ''
      runHook preBuild
      echo ""
      echo "══════════════════════════════════════════════════════════════"
      echo "  NIRI CONFIG VALIDATION PREFLIGHT"
      echo "══════════════════════════════════════════════════════════════"
      echo ""
      niri validate --config $src
      echo ""
      echo "  ✓ Niri config is valid"
      echo "══════════════════════════════════════════════════════════════"
      runHook postBuild
    '';
    installPhase = ''
      mkdir -p $out
      echo "validated" > $out/status
    '';
  };
in {
  # TEAM_425: Force evaluation of validation before home activation
  home.file.".cache/niri-config-validated".source = niriValidation;

  # TEAM_448: Wayland session variables for native Wayland apps
  # Without these, Electron/Chromium apps fall back to X11/XWayland
  home.sessionVariables = {
    # Electron apps (windsurf, vscode, etc.) - use Wayland natively
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    
    # Qt apps
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    
    # GTK apps
    GDK_BACKEND = "wayland";
    
    # SDL apps
    SDL_VIDEODRIVER = "wayland";
    
    # Firefox
    MOZ_ENABLE_WAYLAND = "1";
    
    # General Wayland
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "niri";
  };

  # TEAM_448: Use mkOutOfStoreSymlink for dotfiles (the canonical way)
  # This creates a symlink chain: ~/.config/X → store/hm-files/X → store/hm_X → /actual/repo/path
  # The final target IS the repo path, enabling instant edits without rebuild.
  # NOTE: Must use absolute string paths (not Nix paths like ./dotfiles)
  xdg.configFile = {
    "niri".source = mkSymlink "niri";
    "rofi".source = mkSymlink "rofi";
    "waybar".source = mkSymlink "waybar";
  };
}
