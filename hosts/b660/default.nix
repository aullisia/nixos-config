{ pkgs, ... }:

{
  imports =
  [
    ./hardware-configuration.nix
  ];

  programs.wayfire = {
    enable = true;
    plugins = with pkgs.wayfirePlugins; [
      wcm
      wf-shell
      wayfire-plugins-extra
    ];
  };

  environment.systemPackages = with pkgs; [
    cowsay
  ];
}