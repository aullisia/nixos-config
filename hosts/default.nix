{ inputs, nixpkgs, unstable-pkgs, home-manager, nix-flatpak, plasma-manager, spicetify-nix, niri, quickshell, vars, ... }:

let
  system = "x86_64-linux";
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  unstable = import unstable-pkgs {
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
        home-manager.extraSpecialArgs = { inherit dotFilesPath quickshell modulesPath vars unstable spicetify-nix; };
        home-manager.users."${vars.user}" = {
          imports = [
            nix-flatpak.homeManagerModules.nix-flatpak
            plasma-manager.homeManagerModules.plasma-manager
            inputs.spicetify-nix.homeManagerModules.default
            niri.homeModules.niri
            ./b660/home.nix
          ];
        };
      }
    ];
    specialArgs = { inherit vars unstable; };
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
        home-manager.extraSpecialArgs = { inherit dotFilesPath modulesPath vars unstable spicetify-nix; };
        home-manager.users."${vars.user}" = {
          imports = [
            nix-flatpak.homeManagerModules.nix-flatpak
            plasma-manager.homeManagerModules.plasma-manager
            inputs.spicetify-nix.homeManagerModules.default
            ./vivobook/home.nix
          ];
        };
      }
    ];
    specialArgs = { inherit vars unstable; };
  };
}