# Uses code from https://github.com/Ly-sec/nixos/tree/main/home/quickshell

{ config, lib, pkgs, vars, quickshell, ... }:

let
  myQuickshell = quickshell.packages.${pkgs.system}.default;

  homeDir = config.home.homeDirectory;
  quickshellDir = "${homeDir}/nixos-config/modules/programs/quickshell/qml";
  quickshellTarget = "${homeDir}/.config/quickshell";
  faceIconSource = "${homeDir}/nixos-config/assets/profile.png";
  faceIconTarget = "${homeDir}/.face.icon";
in {
  home.packages = with pkgs; [
    myQuickshell
    qt6Packages.qt5compat
    libsForQt5.qt5.qtgraphicaleffects
    kdePackages.qtbase
    kdePackages.qtdeclarative
    kdePackages.qtstyleplugin-kvantum
    wallust
  ];

  home.activation.symlinkQuickshellAndFaceIcon = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ln -sfn "${quickshellDir}" "${quickshellTarget}"
    ln -sfn "${faceIconSource}" "${faceIconTarget}"
  '';
}