{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=release-24.11";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        aul = lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.aul = {
                imports = [ ./home.nix ];
              };
            }
          ];
        };
      };
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
