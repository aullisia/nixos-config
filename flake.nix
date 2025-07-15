{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=release-25.05";
    unstable-pkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager.url = "github:nix-community/plasma-manager";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.5.2";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
  };

  outputs = inputs @ { self, nixpkgs, unstable-pkgs, home-manager, nix-flatpak, plasma-manager, spicetify-nix, ... }:
    let
      vars = {
        user = "aul";
      };
    in {
      nixosConfigurations = (
        import ./hosts {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs unstable-pkgs home-manager nix-flatpak plasma-manager spicetify-nix vars;
        }
      );
    };
}
