{ config, pkgs, lib, spicetify-nix, ... }:
{
  programs.spicetify =
  let
    spicePkgs = spicetify-nix.legacyPackages.${pkgs.system};
  in
  {
    enable = true;
    theme = lib.mkForce spicePkgs.themes.text;
    colorScheme = lib.mkForce "CatppuccinMocha";
  };
}