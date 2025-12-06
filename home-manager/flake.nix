# TEAM_424: Standalone home-manager for Fedora KDE
{
  description = "Vince's home-manager config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { nixpkgs, home-manager, plasma-manager, ... }:
    let
      system = "x86_64-linux";
      
      # Custom packages overlay
      darkwallOverlay = final: prev: {
        darkwall-windsurf = final.callPackage ./packages/windsurf.nix { };
      };
      
      # TEAM_426: Allow unfree packages (e.g., windsurf)
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ darkwallOverlay ];
      };
      # TEAM_425: Define config directory once for portable symlinks
      configDir = "/home/vince/.config/nix-home-manager";
    in {
      homeConfigurations."vince" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit configDir; };
        modules = [
          plasma-manager.homeModules.plasma-manager
          ./home.nix
        ];
      };
    };
}
