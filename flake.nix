# TEAM_427: NixOS + Home Manager flake configuration
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

    # TEAM_446: Agenix for secrets management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, agenix, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Custom packages overlay
      darkwallOverlay = final: prev: {
        darkwall-windsurf = final.callPackage ./packages/darkwall-windsurf { };
      };

      # Shared module args passed to all modules
      specialArgs = {
        inherit inputs self;
        flakePath = builtins.toString self.outPath;  # Portable path to flake root
      };

      # Shared NixOS modules for all hosts
      sharedModules = [
        # TEAM_446: Agenix for secrets management
        agenix.nixosModules.default
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
        ./modules/secrets
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

        # TEAM_434: Daily driver desktop (dual-boot with Fedora)
        blep = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = sharedModules ++ [
            ./hosts/blep
          ];
        };

        # TEAM_434: Headless GPU server (ComfyUI, service accounts only)
        workstation = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            # Server doesn't need desktop modules or home-manager users
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [ darkwallOverlay ];
            }
            ./modules/system
            ./hosts/workstation
          ];
        };
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
          extraSpecialArgs = specialArgs;
          modules = [
            plasma-manager.homeModules.plasma-manager
            ./home/vince/standalone.nix
          ];
        };
      };

      # ════════════════════════════════════════════════════════════════
      # Development Shell (for contributors)
      # ════════════════════════════════════════════════════════════════
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nixfmt-rfc-style  # Nix formatter
          nil               # Nix LSP
          just              # Command runner
        ];
      };

      # ════════════════════════════════════════════════════════════════
      # Formatter (nix fmt)
      # ════════════════════════════════════════════════════════════════
      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
