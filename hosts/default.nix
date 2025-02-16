{ inputs, nixpkgs, home-manager, nix-flatpak, vars, ... }:

let
  system = "x86_64-linux";
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  lib = nixpkgs.lib;
  dotFilesPath = "../../dotfiles";
  modulesPath = "../../modules";
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
        home-manager.extraSpecialArgs = { inherit dotFilesPath; inherit modulesPath; inherit vars; };
        home-manager.users."${vars.user}" = {
          imports = [
            nix-flatpak.homeManagerModules.nix-flatpak
            ./b660/home.nix
          ];
        };
      }
    ];
    specialArgs = { inherit vars; };
  };
  vivobook = lib.nixosSystem {
    inherit system;
    modules = [
      nix-flatpak.nixosModules.nix-flatpak

      ./vivobook
      ./configuration.nix

      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit dotFilesPath; inherit modulesPath; inherit vars; };
        home-manager.users."${vars.user}" = {
          imports = [
            nix-flatpak.homeManagerModules.nix-flatpak
            ./vivobook/home.nix
          ];
        };
      }
    ];
    specialArgs = { inherit vars; };
  };
}