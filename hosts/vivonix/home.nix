{ config, pkgs, inputs, self, vars, ... }:
let
  allPackages = import ./home-packages.nix { inherit pkgs; };

  nixPackages = builtins.filter (p: !(builtins.isAttrs p && builtins.hasAttr "isFlatpak" p && p.isFlatpak)) allPackages;
  flatpaks = builtins.map (p: builtins.removeAttrs p [ "isFlatpak" ]) (
    builtins.filter (p: builtins.isAttrs p && builtins.hasAttr "isFlatpak" p && p.isFlatpak) allPackages
  );
in
{
  home.username = "${vars.user}";
  home.homeDirectory = "/home/${vars.user}";
  home.stateVersion = "25.05";

  imports = [
    "${self}/modules/shell/starship.nix"
    "${self}/modules/programs/ghostty.nix"
    "${self}/modules/programs/librewolf.nix"
    "${self}/modules/programs/walker"
    "${self}/modules/services/wallpapers.nix"
    "${self}/modules/programs/spicetify.nix"
    "${self}/modules/programs/fastfetch"
    "${self}/modules/programs/vscode"
  ];

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  home.packages = nixPackages;
  services.flatpak.packages = flatpaks;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}