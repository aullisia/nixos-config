{ inputs, nixpkgs, unstable-pkgs, home-manager, nix-flatpak, plasma-manager, niri, spicetify-nix, quickshell, stylix, vars, ... }:

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
      stylix.nixosModules.stylix

      ./b660
      ./configuration.nix

      ({pkgs, ...}: {
        environment.systemPackages = [
          (quickshell.packages.${pkgs.system}.default.override {
            withJemalloc = true;
            withQtSvg = true;
            withWayland = true;
            withX11 = false;
            withPipewire = true;
            withPam = true;
            withHyprland = true;
            withI3 = false;
          })
        ];
      })

      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = { inherit dotFilesPath spicetify-nix quickshell modulesPath vars unstable; };
        home-manager.users."${vars.user}" = {
          imports = [
            nix-flatpak.homeManagerModules.nix-flatpak
            plasma-manager.homeManagerModules.plasma-manager
            niri.homeModules.niri
            inputs.spicetify-nix.homeManagerModules.default
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
        home-manager.extraSpecialArgs = { inherit dotFilesPath modulesPath vars unstable; };
        home-manager.users."${vars.user}" = {
          imports = [
            nix-flatpak.homeManagerModules.nix-flatpak
            plasma-manager.homeManagerModules.plasma-manager
            ./vivobook/home.nix
          ];
        };
      }
    ];
    specialArgs = { inherit vars unstable; };
  };
}