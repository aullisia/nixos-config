{ config, lib, pkgs, vars, self, inputs, ... }:

let
  myQuickshell = inputs.quickshell.packages.${pkgs.system}.default;
  homeDir = config.home.homeDirectory;

  quickshellDir = "${self}/modules/programs/quickshell/qml";
  quickshellTarget = "${homeDir}/.config/quickshell";

  faceIconSource = "${self}/rsc/img/profile.png";
  faceIconTarget = "${homeDir}/face.png";
in {
  home.packages = with pkgs; [
    myQuickshell
  ];

  home.activation.symlinkQuickshellAndFaceIcon = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ln -sfn "${quickshellDir}" "${quickshellTarget}"
    cp -f "${faceIconSource}" "${faceIconTarget}"
  '';
}