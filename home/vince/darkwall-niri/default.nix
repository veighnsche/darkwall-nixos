# TEAM_442: Phase 3 - Niri configuration
# TEAM_443: Refactored to use symlinks (like darkwall-windsurf)
# TEAM_425: Added build-time niri config validation preflight
# Config files live in ./dotfiles/ and are symlinked to ~/.config/
{ config, pkgs, lib, flakePath, ... }:

let
  dotfilesPath = "${flakePath}/home/vince/darkwall-niri/dotfiles";
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

  # TEAM_443: Symlink all wayland config folders - edits are instant, no rebuild needed
  xdg.configFile = {
    "niri" = {
      source = mkSymlink "niri";
      force = true;
    };
    "rofi" = {
      source = mkSymlink "rofi";
      force = true;
    };
    "waybar" = {
      source = mkSymlink "waybar";
      force = true;
    };
  };
}
