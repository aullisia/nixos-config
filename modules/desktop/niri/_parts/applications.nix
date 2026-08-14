{ pkgs }:

{
  browser = "${pkgs.librewolf}/bin/librewolf";
  terminal = "${pkgs.ghostty}/bin/ghostty";
  fileManager = "${pkgs.nemo}/bin/nemo";
  # appLauncher = "${pkgs.walker}/bin/walker";
}
