{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=release-25.05";
    # nixpkgs.url = "github:nixos/nixpkgs?ref=release-25.05";
    #nixpkgs.url = "github:NixOS/nixpkgs/d0e4c12e6c18d4d8b1e56f19a1fb4bbe48d5d4f5";
    unstable-pkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager.url = "github:nix-community/plasma-manager";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.5.2";
  };

  outputs = inputs @ { self, nixpkgs, unstable-pkgs, home-manager, nix-flatpak, plasma-manager, ... }:
    let
      vars = {
        user = "aul";
      };
    in {
      nixosConfigurations = (
        import ./hosts {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs unstable-pkgs home-manager nix-flatpak plasma-manager vars;
        }
      );
    };
}
