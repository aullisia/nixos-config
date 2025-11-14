{ config, lib, pkgs, vars, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    inputs.noctalia.packages.${system}.default
  ];

  fonts.packages = with pkgs; [
    material-symbols
    roboto
    inter-nerdfont
  ];

  home-manager.users."${vars.user}" = {
    imports = [
       inputs.noctalia.homeModules.default
      ./home.nix
    ];
  };
}