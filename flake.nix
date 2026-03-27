{
  description = "My personal NixOS flake for personal computers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=release-25.11";
    #nixpkgs.url = "github:nixos/nixpkgs/c2db45be354486ed8b62672c710d665bd53824c5";

    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri.url = "github:sodiboo/niri-flake";

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
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
