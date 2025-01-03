{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=release-24.11";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.5.2";
  };

  outputs = inputs @ { self, nixpkgs, home-manager, nix-flatpak, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
      flakeRoot = toString self.repoDir;
    in {
      nixosConfigurations = (
        import ./hosts {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs home-manager nix-flatpak flakeRoot;
        }
      );

      # nixosConfigurations = {
      #   aul = lib.nixosSystem {
      #     inherit system;
      #     modules = [
      #       nix-flatpak.nixosModules.nix-flatpak
      #       ./configuration.nix
      #       home-manager.nixosModules.home-manager {
      #         home-manager.useGlobalPkgs = true;
      #         home-manager.useUserPackages = true;
      #         home-manager.users.aul = {
      #           imports = [
      #             nix-flatpak.homeManagerModules.nix-flatpak
      #             ./home.nix
      #           ];
      #         };
      #       }
      #     ];
      #   };
      # };


      #  hmConfig = {
      #  test = home-manager.lib.homeManagerConfiguration {
      #    inherit system pkgs;
      #    username = "test";
      #    homeDirectory = "/home/test";
      #    configuration = {
      #      imports = [
      #        ./home.nix
      #      ];
      #    };
      #  };
    };
}
