{ config, pkgs, lib, inputs, ... }:

{
  programs.spicetify =
  let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  in
  {
    enable = true;
    theme = lib.mkForce spicePkgs.themes.text;
    colorScheme = lib.mkForce "CatppuccinMocha";
  };
}