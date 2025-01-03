{ inputs, nixpkgs, home-manager, nix-flatpak, ... }:

let
  system = "x86_64-linux";
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  lib = nixpkgs.lib;
in
{
  b660 = lib.nixosSystem {
    inherit system;
    modules = [
      nix-flatpak.nixosModules.nix-flatpak

      ./b660
      ./configuration.nix

      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.aul = {
          imports = [
            nix-flatpak.homeManagerModules.nix-flatpak
            ./b660/home.nix
          ];
        };
      }
    ];
  };
}