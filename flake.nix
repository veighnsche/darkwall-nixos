# TEAM_426: NixOS + Home Manager flake configuration
# Architecture based on https://nixos-and-flakes.thiscute.world/
{
  description = "darkwall NixOS configuration";

  inputs = {
    # NixOS official package source
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager for user-level configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Plasma Manager for KDE configuration
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, ... }@inputs:
    let
      system = "x86_64-linux";

      # Custom packages overlay
      darkwallOverlay = final: prev: {
        darkwall-windsurf = final.callPackage ./packages/windsurf.nix { };
      };

      # Shared module args passed to all modules
      specialArgs = {
        inherit inputs;
        # Path to this flake for dotfile symlinks
        flakePath = "/home/vince/Projects/darkwall-nixos";
      };

      # Shared NixOS modules for all hosts
      sharedModules = [
        # Make home-manager available as NixOS module
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = specialArgs;
            sharedModules = [
              plasma-manager.homeModules.plasma-manager
            ];
          };
          # Apply overlay globally
          nixpkgs.overlays = [ darkwallOverlay ];
        }
        # Import shared system modules
        ./modules/system
        ./modules/desktop
        ./modules/users
      ];

    in {
      # ════════════════════════════════════════════════════════════════
      # NixOS Configurations (system-level)
      # ════════════════════════════════════════════════════════════════
      nixosConfigurations = {
        # VM for testing
        vm-test = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = sharedModules ++ [
            ./hosts/vm-test
          ];
        };

        # Future: real hardware
        # darkwall = nixpkgs.lib.nixosSystem {
        #   inherit system specialArgs;
        #   modules = sharedModules ++ [
        #     ./hosts/darkwall
        #   ];
        # };
      };

      # ════════════════════════════════════════════════════════════════
      # Standalone Home Manager (for non-NixOS systems like Fedora)
      # ════════════════════════════════════════════════════════════════
      homeConfigurations = {
        "vince@fedora" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ darkwallOverlay ];
          };
          extraSpecialArgs = specialArgs // {
            configDir = "/home/vince/.config/nix-home-manager";
          };
          modules = [
            plasma-manager.homeModules.plasma-manager
            ./home/vince/standalone.nix
          ];
        };
      };
    };
}
