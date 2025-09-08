{ inputs, self, vars, ...}: 

let
  system = "x86_64-linux";
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
  home-manager = inputs.home-manager;
  niri = inputs.niri;
  stylix = inputs.stylix;
  lib = inputs.nixpkgs.lib;
in
{
  vivonix = lib.nixosSystem {
    inherit system;
    modules = [
      stylix.nixosModules.stylix

      ./vivonix/configuration.nix
      ./configuration.nix

      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit inputs self vars; };
        home-manager.users."${vars.user}" = {
          imports = [
            niri.homeModules.niri
            inputs.nix-flatpak.homeManagerModules.nix-flatpak
            inputs.spicetify-nix.homeManagerModules.default

            ./vivonix/home.nix
          ];
        };
      }
    ];
    specialArgs = { inherit self inputs vars; };
  };
}