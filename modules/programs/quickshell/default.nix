# Uses code from https://github.com/Ly-sec/nixos/tree/main/home/quickshell

{ config, lib, pkgs, vars, quickshell, ... }:

{
  environment.systemPackages = with pkgs; [
    qt6Packages.qt5compat
    # libsForQt5.qt5.qtgraphicaleffects
    kdePackages.qtbase
    kdePackages.qtdeclarative
    kdePackages.qtstyleplugin-kvantum
    wallust
  ];

  home-manager.users."${vars.user}" = {
    imports = [
      ./home.nix
    ];
  };
}