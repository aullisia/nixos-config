{ config, lib, pkgs, vars, ... }:

{
  environment.systemPackages = with pkgs; [
    qt6Packages.qt5compat
    kdePackages.qtbase
    kdePackages.qtdeclarative
    kdePackages.qtstyleplugin-kvantum

    bluez
    brightnessctl
    cava
    cliphist
    file
    findutils
    gpu-screen-recorder
    libnotify
    mutagen
    cliphist
  ];

  fonts.packages = with pkgs; [
    material-symbols
    roboto
    inter-nerdfont
  ];

  home-manager.users."${vars.user}" = {
    imports = [
      ./home.nix
    ];
  };
}