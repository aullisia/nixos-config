{
  description = "My personal NixOS flake for personal computers";

  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs?ref=release-25.05";
    nixpkgs.url = "github:nixos/nixpkgs/d8e9defc04d49cfc48edbd0ffee38f3ded52b13d";

    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    stylix = {
      url = "github:nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri.url = "github:sodiboo/niri-flake";

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs = inputs @ { self, ...}: 
  let
    vars = {
      user = "aul";
    };
  in
  {
    nixosConfigurations = (
      import ./hosts {
        inherit self inputs vars;
      }
    );
  };
}
